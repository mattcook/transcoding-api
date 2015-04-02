class FFMPEG
  MP4 = 'mp4'
  WEBM = 'webm'
  @@timeout = 30

  def initialize(video, output='ouput1', options = {})
    @video = video
    @options = nil
    # @options = "-acodec libfaac -b:a 128k -vcodec mpeg4 -b:v 1200k -flags +aic+mv4"
    @format = MP4
    @output_file = output.concat('.').concat(@format)
  end

  def run(&block)
    transcode_video(&block)
  end

  private
  def transcode_video
    puts "TRANSCODING?"
    puts @video.to_json
    if @format == MP4
      @video.mp4 = @output_file
    elsif @format == WEBM
      @video.webm = @output_file
    end

    @command = "ffmpeg -y -i #{@video.original} #{@output_file}"
    puts "_#{@command}"
    @output = ''
    redis = Redis.new

    Open3.popen3(@command) do |stdin, stdout, stderr, wait_thr|
      begin
        next_line = Proc.new do |line|
          if line.include?("time=")
            if line =~ /time=(\d+):(\d+):(\d+.\d+)/
              time = ($1.to_i * 3600) + ($2.to_i * 60) + $3.to_f
            else
              time = 0.0
            end
            @video.progress = ((time / @video.duration) * 100).to_i
            redis.set(@video.id, @video.to_json)
          end
        end

        if @@timeout
          stderr.each_with_timeout(wait_thr.pid, @@timeout, 'size=', &next_line)
        else
          stderr.each('size=', &next_line)
        end

      rescue Timeout::Error => e
        raise Error, "Process hung. Full output: #{@output}"
      end
    end
  end
end

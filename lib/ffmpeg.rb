class FFMPEG

 # http://s3.amazonaws.com/cp476-videos/ouput1.mp4

  @@timeout = 30

  def initialize(video, output='ouput1.mp4', options = {})
    @video = video
    @options = nil
    #@options = "-acodec libfaac -b:a 128k -vcodec mpeg4 -b:v 1200k -flags +aic+mv4"
    @output_file = output
  end

  def run(&block)
    transcode_video(&block)
    # if @options[:validate]
    #   validate_output_file(&block)
    #   return encoded
    # else
    #   return nil
    # end
  end

  def status
    @info
  end

  private
  def transcode_video
    redis = Redis.new
    @command = "ffmpeg -y -i #{@video.path} #{@options} #{@output_file}"
    @output = ""
    Open3.popen3(@command) do |stdin, stdout, stderr, wait_thr|
      puts wait_thr.pid
      begin
        next_line = Proc.new do |line|
          if line.include?("time=")
            if line =~ /time=(\d+):(\d+):(\d+.\d+)/
              time = ($1.to_i * 3600) + ($2.to_i * 60) + $3.to_f
            else
              time = 0.0
            end
            progress = ((time / @video.duration) * 100).round(2)
            redis.set(@video.id, progress)
            puts progress
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

class FFMPEG
 # http://s3.amazonaws.com/cp476-videos/ouput1.mp4
  def initialize(video, output='ouput1.mp4', options = {})
    @video = video
    @options = "-acodec libfaac -b:a 128k -vcodec mpeg4 -b:v 1200k -flags +aic+mv4"
    @output_file = output
  end

  def run(&block)
    transcode_video(&block)
    if @options[:validate]
      validate_output_file(&block)
      return encoded
    else
      return nil
    end
  end

  def status
    @info
  end

  private
  def transcode_video
    @command = "ffmpeg -y -i #{@video.path} #{@options} #{@output_file}"
    @output = ""
    Open3.popen3(@command) do |stdin, stdout, stderr, wait_thr|
      begin
        yield(0.0) if block_given?
        next_line = Proc.new do |line|
          @output << line
          if line.include?("time=")
            if line =~ /time=(\d+):(\d+):(\d+.\d+)/
              time = ($1.to_i * 3600) + ($2.to_i * 60) + $3.to_f
            else
              time = 0.0
            end
            progress = (time / @video.duration) * 100
            puts progress.to_i
            yield(progress) if block_given?
          end
        end

        stderr.each('size=', &next_line)

      rescue Timeout::Error => e
        raise Error, "Process hung. Full output: #{@output}"
      end
    end
  end
end

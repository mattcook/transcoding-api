class Video
  attr_reader :path, :duration

  def initialize(path)
    url = URI.parse(path)
    req = Net::HTTP.new(url.host, url.port)
    res = req.request_head(url.path)
    if res.code != "200"
      raise Exeception.new("the url is not accessible")
    end

    @path = path

    command = "ffmpeg -i #{path}"
    output = Open3.popen3(command) { |stdin, stdout, stderr| stderr.read }

    output[/Duration: (\d{2}):(\d{2}):(\d{2}\.\d{2})/]
    @duration = ($1.to_i*60*60) + ($2.to_i*60) + $3.to_f
  end

  def transcode(output_file, options = nil, &block)
    FFMPEG.new(self).run &block
  end
end

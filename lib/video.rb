class Video
  attr_reader :id, :name, :original, :duration
  attr_accessor :mp4, :webm, :progress

  def initialize(path, id=nil)
    redis = Redis.new
    unless File.exists?(path)
      url = URI.parse(path)
      req = Net::HTTP.new(url.host, url.port)
      res = req.request_head(url.path)
      if res.code != "200"
        raise Exeception.new("the url is not accessible")
      end
    end
    @original = path
    if id
      @id = id
      @name = 'This is my new output video'
      @duration = meta_data(path)
    else
      @id = rand.to_s[2..11]
    end
    redis.set(@id, self.to_json)
  end

  def transcode(output_file, options = nil, &block)
    Resque.redis = Redis.new
    Resque.enqueue(Job, @id, @original)
    @progress = 0
    self.to_json
  end

  def to_json
    {id: @id, name: @name, duration: @duration, original: @original, mp4: @mp4, webm: @webm, progress: @progress }.to_json
  end

  private
  def meta_data(link)
    command = "ffmpeg -i #{link}"
    output = Open3.popen3(command) { |stdin, stdout, stderr| stderr.read }

    output[/Duration: (\d{2}):(\d{2}):(\d{2}\.\d{2})/]
    duration = ($1.to_i*60*60) + ($2.to_i*60) + $3.to_f
  end




end

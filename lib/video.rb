class Video
  attr_reader :id, :name, :original, :duration, :bitrate
  attr_accessor :mp4, :webm, :progress

  def initialize(path, id=nil)
    redis = Redis.new
    @original = path

    if id
      @id = id
      name, @duration, @bitrate = meta_data(path)
      if name.nil?
        @name = File.basename(path,File.extname(path))
      else
        @name = name
      end
      redis.set(@id, self.to_json)
    else
      @id = rand.to_s[2..11]
    end
  end

  def transcode(session, options = nil, &block)
    Resque.redis = Redis.new
    Resque.enqueue(Job, @id, @original, session)
    self.to_json
  end

  def to_json
    {id: @id, name: @name, duration: @duration, original: @original, mp4: @mp4, webm: @webm, progress: @progress }.to_json
  end

  private
  def meta_data(link)
    FFMPEG.probe(link)
  end
end

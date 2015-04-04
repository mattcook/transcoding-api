require 'sinatra'
require './config/initialize.rb'

module Job
  @queue = :default

  def self.perform(id, path)
    s3 = AwsApi.new(KEY GOES HERE, SECRET GOES HERE)
    redis = Redis.new
    @video = Video.new(path, id)

    file_name = @video.name

    FFMPEG.new(@video, file_name, "mp4").run
    key = "sessi23213on/#{file_name}"
    s3.upload(key, "tmp/#{file_name}")
    @video.mp4 = s3.get(file_name)
    File.delete("tmp/#{file_name}")
    @video.progress = 100

    # FFMPEG.new(@video, file_name, 'webm').run
    # key = "session/#{file_name}"
    # s3.upload(key, "tmp/#{file_name}")
    # @video.mp4 = s3.get(file_name)
    # File.delete(file_name)
    # @video.progress = 100

    redis.set(@video.id, @video.to_json)
  end
end

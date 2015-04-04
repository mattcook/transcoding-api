require 'sinatra'
require './config/initialize.rb'

class Job < Sinatra::Base
  register Sinatra::ConfigFile
  config_file 'config.yml'

  @queue = :default

  def self.perform(id, path, session)
    s3 = AwsApi.new(settings.aws_key, settings.aws_secret)
    redis = Redis.new
    @video = Video.new(path, id)

    mp4 = "#{@video.name}.mp4"
    webm = "#{@video.name}.webm"

    FFMPEG.new(@video, mp4, "mp4").run
    key = "#{session}/#{mp4}"
    s3.upload(key, "tmp/#{mp4}")
    @video.mp4 = s3.get("#{session}/#{mp4}")
    File.delete("tmp/#{mp4}")

    FFMPEG.new(@video, webm, 'webm').run
    key = "session/#{webm}"
    s3.upload(key, "tmp/#{webm}")
    @video.webm = s3.get("#{session}/#{webm}")
    File.delete("tmp/#{webm}")

    @video.progress = 100

    redis.set(@video.id, @video.to_json)
  end
end

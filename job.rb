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
    mp4_options = "-acodec aac -b:a 128k -vcodec mpeg4 -b:v 1200k -flags +aic+mv4 -strict -2"
    webm_options = "-acodec libvorbis -ac 2 -b:a 96k -ar 44100 -b:v 345k -s 640x360"

    FFMPEG.new(@video, mp4, "mp4", mp4_options).run
    key = "#{session}/#{mp4}"
    s3.upload(key, "tmp/#{mp4}", 'mp4')
    @video.mp4 = s3.get("#{session}/#{mp4}")


    redis.set(@video.id, @video.to_json)
    FFMPEG.new(@video, webm, 'webm', nil).run
    key = "#{session}/#{webm}"
    s3.upload(key, "tmp/#{webm}", 'webm')

    @video.webm = s3.get("#{session}/#{webm}")
    @video.progress = 100
    redis.set(@video.id, @video.to_json)

    # clean up files
    File.delete("tmp/#{mp4}")
    File.delete("tmp/#{webm}")
  end
end

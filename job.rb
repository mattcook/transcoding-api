require 'sinatra'
require "./config/initialize.rb"

module Job
  @queue = :default

  def self.perform(id, path)
    video = Video.new(path, id)
    FFMPEG.new(video).run
  end
end

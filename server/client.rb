require 'sinatra'
require "./config/initialize.rb"

if ENV['ENV'] == 'production'
  set :port, 80
  set :bind, '0.0.0.0'
end

# http://localhost:4567/probe?link=https://s3.amazonaws.com/cp476-videos/test.mp4
get '/probe' do
  video_link = params[:link].sub('https', 'http').sub(" ","+")
  Probe.new(video_link).contents
end

get '/transcode/create' do
  link = params[:link].sub('https', 'http').sub(" ","+")
  video = Video.new(link)
  id = video.transcode('output.mp4')
#  redirect "/transcode/#{id}"
end

get '/transcode/:id' do
  redis = Redis.new
  progress = redis.get(params[:id])
  progress.to_s
end

# get 'auth' do
#   s3 = AWS::S3.new
#   bucket = s3.buckets['mybucket']
#
#   s3_file = bucket.objects[filename_variable]
#   public_url = s3_file.public_url.to_s
#
#   movie = FFMPEG::Movie.new(public_url.to_s.sub('https', 'http'))
#
# end

get '/console' do
  binding.pry
end

require 'sinatra'
require 'sinatra/config_file'
require './config/initialize.rb'

config_file '../config.yml'

if ENV['ENV'] == 'production'
  set :port, 80
  set :bind, '0.0.0.0'
end

get '/transcode/create' do
  link = params[:link].sub('https', 'http').sub(" ","+")
  video = Video.new(link)
  id = video.transcode('output.mp4')

end

get '/transcode/:id' do
  redis = Redis.new
  progress = redis.get(params[:id])
  progress.to_s
end

get '/' do
  s3 = AwsApi.new(settings.aws_key, settings.aws_secret)
  s3.get_file('output.mp4')
end

get '/upload/:session' do
  s3 = AwsApi.new(settings.aws_key, settings.aws_secret)
  resp = s3.upload(params[:session])
  {url: resp.url, fields: resp.fields}
end

get '/console' do
  binding.pry
end

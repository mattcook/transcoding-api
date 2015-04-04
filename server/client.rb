require 'sinatra'
require 'sinatra/config_file'

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
  @greeting = settings.aws_key
end

get '/console' do
  binding.pry
end

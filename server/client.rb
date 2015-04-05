require 'sinatra'
require 'sinatra/config_file'
require './config/initialize.rb'

config_file '../config.yml'

if ENV['ENV'] == 'production'
  set :port, 80
  set :bind, '0.0.0.0'
end

s3 = AwsApi.new(settings.aws_key, settings.aws_secret)

before do
   content_type :json
   headers 'Access-Control-Allow-Origin' => '*',
            'Access-Control-Allow-Methods' => ['OPTIONS', 'GET', 'POST']
end

post '/transcode/:session/' do
  s3_link = s3.get(params[:file_name])
  video = Video.new(s3_link)
  id = video.transcode(params[:session])
end

get '/transcode/:id' do
  redis = Redis.new
  video = redis.get(params[:id])
  video.to_s
end

get '/' do
  output = FFMPEG.probe(params[:link])
  output.to_s
end

get '/upload/:name' do
  resp = s3.presigned_upload(params[:name])
  {url: resp.url, fields: resp.fields}
end

get '/console' do
  binding.pry
end

require 'sinatra'
require 'sinatra/config_file'
require './config/initialize.rb'

config_file '../config.yml'

configure { set :server, :puma }

if ENV['ENV'] == 'production'
  set :bind, '0.0.0.0'
end

s3 = AwsApi.new(settings.aws_key, settings.aws_secret)

before do
  headers 'Access-Control-Allow-Origin' => '*'
  headers 'Access-Control-Allow-Headers' => '*'
  headers 'Access-Control-Allow-Methods' => 'GET,POST,PUT,DELETE,OPTIONS'
end

options "*" do
  response.headers["Allow"] = "HEAD,GET,PUT,POST,DELETE,OPTIONS"
  response.headers["Access-Control-Allow-Headers"] = "X-Requested-With, X-HTTP-Method-Override, Content-Type, Cache-Control, Accept"
  200
end

get '/info/:id' do
  redis = Redis.new
  video = redis.get(params[:id])
  video.to_s
end

post '/transcode' do
  data = JSON.parse(request.body.read)
  s3_link = s3.get(data['file_name'])
  video = Video.new(s3_link)
  id = video.transcode(data['session'])
end

get '/upload/:name' do
  resp = s3.presigned_upload(params[:name])
  {url: resp.url, fields: resp.fields}
end

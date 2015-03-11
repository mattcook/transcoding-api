require 'sinatra'
require "./config/initialize.rb"

if ENV['ENV'] == 'production'
  set :port, 80
  set :bind, '0.0.0.0'
end

get '/probe' do
  video_link = params[:link]
  Probe.new(video_link).contents
end

get '/console' do
  binding.pry
end

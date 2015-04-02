require 'rubygems'
require 'bundler/setup'

Bundler.require

require 'resque'
require 'redis'
require './lib/io_monkey.rb'
require './lib/ffmpeg.rb'
require './lib/probe.rb'
require './lib/video.rb'
require './lib/job.rb'

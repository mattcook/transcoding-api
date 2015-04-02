require 'resque'

module Job
  @queue = :default

  def self.perform(video)
    #FFMPEG.new(video).run
    sleep 5
    puts "Processed a job!"
  end
end

class Probe
  def initialize(video_link)
    video_link['https'] = 'http' if video_link['https']
    probe_command = "ffprobe -print_format json -show_format #{video_link}"
    @contents = open("|#{probe_command}").read()
  end

  def contents
    @contents
  end
end

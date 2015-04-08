# VideoTranscoder
Video Transcoding Repo for Internet Computing Final Project

## Dependencies

- Ruby
- Redis
- FFMPEG

### Installation

```sh
$ bundle install
$ redis-server
$ bundle exec resque work -q default -r ./job.rb
$ ruby server/client.rb or $ bundle exec ruby server/client.rb
```

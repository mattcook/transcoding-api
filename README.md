# VideoTranscoder
Video Transcoding Repo for CP476 Final Project

### Installation

You need Gulp installed globally:

```sh
$ bundle install
$ redis-server
$ bundle exec resque work -q default,failing -r ./job.rb
$ ruby server/client.rb or $ bundle exec ruby server/client.rb
```

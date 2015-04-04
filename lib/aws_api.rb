class AwsApi

  def new
    client = AWS::S3::Base.establish_connection!(
      access_key_id: settings.aws_key,
      secret_access_key: settings.aws_secret
    )
  end

  # get 'auth' do
  #   s3 = AWS::S3.new
  #   bucket = s3.buckets['mybucket']
  #
  #   s3_file = bucket.objects[filename_variable]
  #   public_url = s3_file.public_url.to_s
  #
  #   movie = FFMPEG::Movie.new(public_url.to_s.sub('https', 'http'))
  # end

end

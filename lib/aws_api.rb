class AwsApi
  def initialize(key,secret)
    @s3 = Aws::S3::Resource.new(
      access_key_id: key,
      secret_access_key: secret,
      region: 'us-west-2'
    )

    check_bucket # create bucket if it does not exist

    @s3
  end

  def get(file_name)
    s3_bucket.object(file_name).public_url.gsub('https','http')
  end

  def presigned_upload(file_name)
    s3_bucket.presigned_post(key: file_name, acl: 'public_read')
  end

  def upload(output_key, local_file)
    s3_bucket.put_object(
      key: output_key,
      body: File.open(local_file),
      acl: 'public-read'
    )
  end

  private
  def check_bucket
    begin @s3.client.head_bucket(bucket: 'cp476-vids')
    rescue Aws::S3::Errors::NotFound
      s3_bucket.create(acl: 'public-read')
    end
  end

  def s3_bucket
    @s3.bucket('cp476-vids')
  end
end

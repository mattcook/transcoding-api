class AwsApi
  def initialize(key,secret)
    @s3 = Aws::S3::Resource.new(
      access_key_id: key,
      secret_access_key: secret,
      region: 'us-west-2'
    )

    check_bucket #create bucket if it does not exist

    return @s3
  end

  def get_file(input)
    obj = @s3.bucket('cp476').object(input)
    obj.presigned_url(:get, expires_in: 3600)
  end

  private
  def check_bucket
    begin @s3.client.head_bucket(bucket: 'cp476')
    rescue Aws::S3::Errors::NotFound
      @s3.bucket('cp476').create
    end
  end
end

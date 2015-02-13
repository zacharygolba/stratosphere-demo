Stratosphere.configure do |config|
  config.cloud      = :aws
  config.dir_prefix = Rails.env.development? ? 'stratosphere/dev/demo' : 'stratosphere/demo'
  config.domain     = 'http://cdn.zacharygolba.com'
  config.aws        = {
      access_key: ENV['AWS_ACCESS_KEY_ID'],
      secret: ENV['AWS_SECRET_ACCESS_KEY'],
      region: ENV['AWS_REGION'],
      s3_bucket: 'zacharygolba',
      transcoder: {
          pipeline: '1423810208235-0uqdqn',
          formats: {
              mp4: '1423811919391-onfn8q',
              webm: '1420560244435-h0lpgu'
          }
      }
  }
end
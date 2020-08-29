Shoryuken.configure_client do |config|
  config.sqs_client = Aws::SQS::Client.new(
    region: ENV['AWS_REGION'],
    secret_access_key: ENV['AWS_ACCESS_KEY_ID'],
    access_key_id: ENV['AWS_SECRET_ACCESS_KEY'],
    endpoint: ENV['AWS_SQS_ENDPOINT'],
    verify_checksums: false
  )
end

Shoryuken.configure_server do |config|
  config.sqs_client = Aws::SQS::Client.new(
    region: ENV['AWS_REGION'],
    secret_access_key: ENV['AWS_ACCESS_KEY_ID'],
    access_key_id: ENV['AWS_SECRET_ACCESS_KEY'],
    endpoint: ENV['AWS_SQS_ENDPOINT'],
    verify_checksums: false
  )
end
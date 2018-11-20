require 'vcr'

VCR.configure do |config|
  config.cassette_library_dir = 'test/fixtures/vcr_cassettes'
  config.hook_into :webmock
  config.ignore_localhost = true
  config.allow_http_connections_when_no_cassette = false
  config.filter_sensitive_data('{addr}') { ENV['TEST_ADDR'] }
end

require "codeclimate-test-reporter"
CodeClimate::TestReporter.start

require 'rubygems'
require 'bundler'
begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end
require 'test/unit'
require 'mocha/setup'
require 'shoulda'

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))

require 'data_store'

class Test::Unit::TestCase

  DataStore.configure do |config|
    config.database       = ENV['DB'] || :postgres
    config.enable_logging = false
  end

  def time_now_utc_returns(value)
    time = mock
    Time.stubs(:now).returns(time)
    time.stubs(:utc).returns(value)
  end

end
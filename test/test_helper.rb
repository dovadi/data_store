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
require 'mocha'
require 'shoulda'

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))

require 'data_store'

class Test::Unit::TestCase

  DataStore.configure do |config|
    config.database = ENV['DB'] || :postgres
  end

  def store_test_values(table, values)
    created = 0
    values.each do |value|
      table.model.insert(value: value, created: created)
      created += table.parent.frequency
    end
  end

end
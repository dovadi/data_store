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

  def drop_data_stores
    database = Sequel.sqlite(File.expand_path('../../db/data_store.db', __FILE__))
    begin
      database.drop_table :data_stores
    rescue Sequel::DatabaseError  
    end
  end

end
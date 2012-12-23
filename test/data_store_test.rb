require File.expand_path '../test_helper', __FILE__

class DataStoreTest < Test::Unit::TestCase

  context 'DataStore' do

    should 'have a configuration object' do
      assert_equal true, DataStore.configuration.is_a?(DataStore::Configuration)
    end

    should 'be able to define the configuration' do
      DataStore.configure do |config|
        config.database = :mysql
      end
      assert_equal :mysql, DataStore.configuration.database
    end

  end

end
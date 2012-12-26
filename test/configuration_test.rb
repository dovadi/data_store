require File.expand_path '../test_helper', __FILE__

class ConfigurationTest < Test::Unit::TestCase

  context 'Configuration' do

    should "provide default values" do
      assert_config_default :prefix,             'data_store_'
      assert_config_default :database,           :postgres
      assert_config_default :compression_factor, 5
      assert_config_default :frequency,          10
      assert_config_default :maximum_datapoints, 800
      assert_config_default :data_type,          :float
    end

    should "allow values to be overwritten" do
      assert_config_overridable :prefix
      assert_config_overridable :database
      assert_config_overridable :compression_factor
      assert_config_overridable :frequency
      assert_config_overridable :maximum_datapoints
      assert_config_overridable :data_type
    end

  end

  def assert_config_default(option, default_value, config = nil)
    config ||= DataStore::Configuration.new
    assert_equal default_value, config.send(option)
  end

  def assert_config_overridable(option, value = 'a value')
    config = DataStore::Configuration.new
    config.send(:"#{option}=", value)
    assert_equal value, config.send(option)
  end

end
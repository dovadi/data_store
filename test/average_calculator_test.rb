require File.expand_path '../test_helper', __FILE__

class AverageCalculatorTest < Test::Unit::TestCase

  context 'AverageCalculator' do
  
    setup do
      DataStore::Connector.new.reset!
      @record = DataStore::Base.create(identifier:  1,
                                       type:        'gauge', 
                                       name:        'Electra',
                                       frequency:    10,
                                       description: 'Actual usage of electra in the home',
                                       compression_schema: [2,2,2])

      @calculator = DataStore::AverageCalculator.new 1
      @table = DataStore::Table.new(1)
    end

    should 'be valid' do
      assert @calculator
    end

    should 'return the identifier' do
      assert_equal 1, @calculator.identifier
    end

    should 'return the corresponding compression_schema' do
      assert_equal [2,2,2], @calculator.compression_schema
    end

    should 'return the corresponding compression factors' do
      assert_equal [2,4,8], @calculator.compression_factors
    end

    should 'calculate the first average value' do
      store_test_values(@table, [10,11])
      assert_equal 10.5,  @calculator.perform
    end

  end

end
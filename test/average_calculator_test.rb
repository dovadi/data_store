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

      @table = DataStore::Table.new(1)
      @calculator = DataStore::AverageCalculator.new(@table)
    end

    should 'be valid' do
      assert @calculator
    end

    should 'return the identifier' do
      assert_equal 1, @calculator.identifier
    end

    should 'calculate the average value for the first' do
      @table.model.insert(value: 10, created: 0)
      @table.model.insert(value: 11, created: 10)

      @calculator.perform
      assert_equal 10.5, DataStore::Base.db[:ds_1_2].order(:created).last[:value]
    end

    should 'calculate the average value for the second compression' do
      time_now_utc_returns(10)
     
      @table.model.insert(value: 10, created: 0)
      @table.model.insert(value: 11, created: 10)

      @calculator.perform
      assert_equal 10.5, DataStore::Base.db[:ds_1_2].order(:created).first[:value]

      @table.model.insert(value: 12, created: 30)
      @table.model.insert(value: 13, created: 40)

      time_now_utc_returns(30)

      @calculator.perform
      assert_equal 12.5, DataStore::Base.db[:ds_1_2].order(:created).last[:value]
    end

  end

end
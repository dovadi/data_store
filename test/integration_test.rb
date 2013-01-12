require File.expand_path '../test_helper', __FILE__

class IntegrationTest < Test::Unit::TestCase

  context 'Integration test by adding datapoints through table object' do
  
    setup do
      DataStore::Connector.new.reset!
      @record = DataStore::Base.create(identifier:  1,
                                       type:        'counter', 
                                       name:        'Electra',
                                       frequency:    10,
                                       description: 'Actual usage of gas in the home',
                                       compression_schema: [2,2])

      @table = DataStore::Table.new(1)
      @calculator = DataStore::AverageCalculator.new(@table)
    end

    should 'also calculate the average value' do
      time_now_utc_returns(0)
      @table.add(1000)

      time_now_utc_returns(10)
      @table.add(1010)

      time_now_utc_returns(20)
      @table.add(1020)

      assert_equal 10.0, DataStore::Base.db[:ds_1_2].order(:created).last[:value]
    end

  end

end
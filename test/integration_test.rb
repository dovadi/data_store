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

  context 'Import datapoints (gauge type)' do
    setup do
      start_time  = 1349042407.00000
      values      = [2380.0, 2370.0, 2380.0, 2380.0, 2390.0, 2390.0, 2390.0, 2380.0, 2380.0, 2380.0, 2380.0, 2370.0, 2370.0, 2370.0, 
                     2380.0, 2380.0, 2380.0, 2380.0, 230.0, 230.0, 230.0, 230.0, 230.0, 230.0]
      @datapoints = []
      values.each do |value|
        @datapoints << [value, start_time]
        start_time += rand(9.95..10.05)
      end               
      DataStore::Connector.new.reset!
      @record = DataStore::Base.create(identifier:  1,
                                       type:        'gauge', 
                                       name:        'Electra',
                                       description: 'Actual usage of electra in the home',
                                       compression_schema: [2,3])
      @table = DataStore::Table.new(1)
    end

    should 'store the data and calculate all averages' do
      @table.import(@datapoints)
      assert_equal 24, @table.model.db[:ds_1].count
      assert_equal 12, @table.model.db[:ds_1_2].count
      assert_equal 4, @table.model.db[:ds_1_6].count

      assert_equal 1842, @table.model.db[:ds_1].avg(:value).round
      assert_equal 1842, @table.model.db[:ds_1_2].avg(:value).round
      assert_equal 1842, @table.model.db[:ds_1_6].avg(:value).round
    end
  end

end
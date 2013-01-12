require File.expand_path '../test_helper', __FILE__

class AverageCalculatorTest < Test::Unit::TestCase

  context 'AverageCalculator for a gauge type' do
  
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

    context 'Scenario: adding values according expected frequency' do
      should 'calculate the average values' do
        time_now_utc_returns(10)
       
        @table.model.insert(value: 10, created: 0)
        @table.model.insert(value: 11, created: 10)

        @calculator.perform
        assert_equal 10.5, DataStore::Base.db[:ds_1_2].order(:created).first[:value]       

        @table.model.insert(value: 12, created: 20)
        @table.model.insert(value: 13, created: 30)

        time_now_utc_returns(30)

        @calculator.perform

        assert_equal 12.5, DataStore::Base.db[:ds_1_2].order(:created).last[:value]
        assert_equal 11.5, DataStore::Base.db[:ds_1_4].order(:created).last[:value]

        @table.model.insert(value: 14, created: 40)
        @table.model.insert(value: 15, created: 50)

        time_now_utc_returns(50)

        @calculator.perform

        assert_equal 14.5, DataStore::Base.db[:ds_1_2].order(:created).last[:value]

        @table.model.insert(value: 16, created: 60)
        @table.model.insert(value: 17, created: 70)

        time_now_utc_returns(70)

        @calculator.perform

        assert_equal 16.5, DataStore::Base.db[:ds_1_2].order(:created).last[:value]
        assert_equal 15.5, DataStore::Base.db[:ds_1_4].order(:created).last[:value]
        assert_equal 13.5, DataStore::Base.db[:ds_1_8].order(:created).last[:value]
      end
    end

    context 'Scenario: adding values with an unexpected failure' do
      should 'calculate the average values' do
        time_now_utc_returns(10)
       
        @table.model.insert(value: 10, created: 0)
        @table.model.insert(value: 11, created: 10)

        @calculator.perform
        assert_equal 10.5, DataStore::Base.db[:ds_1_2].order(:created).first[:value]       

        @table.model.insert(value: 12, created: 20)

        #No value at timestamp 30!
        @table.model.insert(value: 14, created: 40)

        time_now_utc_returns(40)

        @calculator.perform

        assert_equal 13.0, DataStore::Base.db[:ds_1_2].order(:created).last[:value]
        assert_equal 11.75, DataStore::Base.db[:ds_1_4].order(:created).last[:value]

        @table.model.insert(value: 15, created: 50)
        @table.model.insert(value: 16, created: 60)

        time_now_utc_returns(60)

        @calculator.perform

        assert_equal 15.5, DataStore::Base.db[:ds_1_2].order(:created).last[:value]

        @table.model.insert(value: 17, created: 70)
        @table.model.insert(value: 18, created: 80)

        time_now_utc_returns(80)

        @calculator.perform

        assert_equal 17.5, DataStore::Base.db[:ds_1_2].order(:created).last[:value]
        assert_equal 16.5, DataStore::Base.db[:ds_1_4].order(:created).last[:value]
        assert_equal 14.125, DataStore::Base.db[:ds_1_8].order(:created).last[:value]
      end
    end
  end

  context 'AverageCalculator for a counter type' do
  
    setup do
      DataStore::Connector.new.reset!
      @record = DataStore::Base.create(identifier:  1,
                                       type:        'counter', 
                                       name:        'Electra',
                                       frequency:    10,
                                       description: 'Actual usage of gas in the home',
                                       compression_schema: [2])

      @table = DataStore::Table.new(1)
      @calculator = DataStore::AverageCalculator.new(@table)
    end

    should 'be valid' do
      assert @calculator
    end

    should 'return the identifier' do
      assert_equal 1, @calculator.identifier
    end

    should 'calculate the average value' do
      @table.model.insert(value: 10, original_value: 1010, created: 10)
      @table.model.insert(value: 10, original_value: 1020, created: 20)
      
      @calculator.perform

      assert_equal 10.0, DataStore::Base.db[:ds_1_2].order(:created).last[:value]
    end

    should 'calculate the average values according to compression_schema' do
      @table.model.insert(value: 10, original_value: 1010, created: 10)
      @table.model.insert(value: 10, original_value: 1020, created: 20)

      time_now_utc_returns(20)      
      @calculator.perform

      @table.model.insert(value: 20, original_value: 1040, created: 30)
      @table.model.insert(value: 30, original_value: 1070, created: 40)

      time_now_utc_returns(40)
      @calculator.perform
     
      assert_equal 25.0, DataStore::Base.db[:ds_1_2].order(:created).last[:value]

      #ds_1_4 already exists through other tests and not removed, but no new average record is added
      assert_equal 0, DataStore::Base.db[:ds_1_4].count 
    end

    should 'calculate the average value by ignoring the original values' do
      @table.model.insert(value: 20, original_value: 12345, created: 10)
      @table.model.insert(value: 30, original_value: 67890, created: 20)
      
      @calculator.perform

      assert_equal 25.0, DataStore::Base.db[:ds_1_2].order(:created).last[:value]
    end

  end

end
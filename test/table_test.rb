require File.expand_path '../test_helper', __FILE__

class TableTest < Test::Unit::TestCase

  context 'DataStore::table general' do

    setup do
      DataStore::Connector.new.reset!
      @record = DataStore::Base.create(identifier:  1,
                                       type:        'gauge', 
                                       name:        'Electra',
                                       description: 'Actual usage of electra in the home',
                                       compression_schema: [5,6,10])
      @table = DataStore::Table.new(1)
    end

    should 'return the value of the identifier' do
      assert_equal 1, @table.identifier
    end

    should 'return the corresponding parent record' do
      assert_equal true, @table.parent.is_a?(DataStore::Base)
      assert_equal 1, @table.parent.identifier
    end

    context 'adding datapoints' do

      setup do
        @table.stubs(:calculate_average_values)
      end

      should 'add a datapoint to the table' do
        @table.add(120.34)
        assert_equal 1, @table.count
      end

      should 'return the last datapoint' do
        @table.add(120.34)
        @table.add(120.38)
        assert_equal 120.38, @table.last.value
      end

      should 'return corresponding model' do
        @table.add(123.45)
        assert_equal 123.45, @table.model.find(value: 123.45).value
      end
    end

    should 'Trigger the average calculator after adding a value' do
      calculator = mock
      DataStore::AverageCalculator.expects(:new).with(@table).returns(calculator)
      calculator.expects(:perform)
      @table.add(120.34)
    end

    should 'Trigger the average calculator after adding a value asynchrone if allow_concurrency is set to tru' do
      DataStore.configuration.expects(:allow_concurrency).returns(true)
      calculator = mock
      DataStore::AverageCalculator.expects(:new).with(@table).returns(calculator)
      calculator.expects(:perform!)
      @table.add(120.34)
    end

    context 'DataStore::table general' do

      setup do
        DataStore::Connector.new.reset!
        @record = DataStore::Base.create(identifier:  1,
                                         type:        'gauge', 
                                         name:        'Electra',
                                         description: 'Actual usage of electra in the home',
                                         compression_schema: [5,6,10])

        @table = DataStore::Table.new(1, 1)
        @table.stubs(:calculate_average_values)
      end

      should 'store a value in the compressed table' do
        @table.add(12345.67)
        assert_equal 12345.67, DataStore::Base.db[:ds_1_5].first[:value]
      end

      should 'store a value in the compressed table with the corresponding index' do
        @table.add(765.432, 3)
        assert_equal 765.432, DataStore::Base.db[:ds_1_300].first[:value]
      end

    end

    context 'with a counter type' do

      setup do
        @record = DataStore::Base.create(identifier:         2,
                                         type:               'counter', 
                                         name:               'Gas',
                                         description:        'Actual usage of natural gas',
                                         compression_schema: [])
        @table = DataStore::Table.new(2)
      end

      context 'adding datapoints' do

        setup do
          @table.stubs(:calculate_average_values)
        end

        should 'add the original value as the first datapoint to the table' do
          @table.add(120123)
          assert_equal 120123, @table.last.value
        end

        should 'storing the difference between current and last value' do
          @table.add(120125)
          @table.add(120127)
          @table.add(120129)
          assert_equal 2, @table.last.value
        end

        should 'remove the very first record after more datapoints' do
          #first record => [#< @values={:id=>1, :value=>120125.0, :original_value=>120125.0, :created=>1358023611.75022}>]
          #So this will be removed in order to maintain a dataset with only 'difference' values
          @table.add(120125) 

          @table.add(120127)
          @table.add(120129)

          assert_equal 2, @table.count
        end

        should 'add the difference when adding datapoints but store orginal value as well' do
          @table.add(120125)
          @table.add(120127)
          assert_equal 120127, @table.last[:original_value] #original_value is not added as column to the Sequel model
        end

      end

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
        start_time += rand(9.00..11.00)
      end               
      DataStore::Connector.new.reset!
      @record = DataStore::Base.create(identifier:  1,
                                       type:        'gauge', 
                                       name:        'Electra',
                                       description: 'Actual usage of electra in the home',
                                       compression_schema: [2,3])
      @table = DataStore::Table.new(1)
    end

    should 'store the data and calculate averages' do
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
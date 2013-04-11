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
      #Need to use any_parameters instead of @table because of Celluloid
      DataStore::AverageCalculator.expects(:new).with(any_parameters).returns(calculator)
      calculator.expects(:perform)
      @table.add(120.34)
    end

    should 'be able to import datapoints' do
      @table.import([[100, 10], [120, 20], [130, 20]])
      assert_equal 3, @table.model.db[:ds_1].count
    end

    context 'fetch' do
      setup do
        @from = Time.now.utc.to_f - 3600
        @till = Time.now.utc.to_f

        @table.model.insert(value: 10, created: @from)
        @table.model.insert(value: 11, created: @from + 10)
      end

      should 'return the datapoints in a given time frame' do
        assert_equal [10.0, 11.0], @table.fetch(:from => @from, :till => @till).map{|datapoint| datapoint[1]}
        assert_equal [@from.round, (@from + 10).round], @table.fetch(:from => @from, :till => @till).map{|datapoint| datapoint[0].round}
      end

      should 'return the datapoints from the corresponding time frame' do
        time = Time.now.utc.to_f

        #Extensive mocking, should we introduce Timeslot object for a more clean and simple test?
        fourth_query = mock
        fourth_query.stubs(:all).returns([])
        third_query  = mock
        third_query.stubs(:order).returns(fourth_query)
        second_query = mock
        second_query.stubs(:where).returns(third_query)
        first_query  = mock
        first_query.stubs(:where).returns(second_query)

        @table.parent.db.expects('[]').with(:ds_1_5).returns(first_query)
        @table.fetch(:from => time, :till => time + 8001)

        @table.parent.db.expects('[]').with(:ds_1_30).returns(first_query)
        @table.fetch(:from => time, :till => time + 40001)
      end

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
        @table.add(765.432, table_index: 3)
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

end
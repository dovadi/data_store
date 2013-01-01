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

      should 'retunr the last datapoint' do
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
      DataStore::AverageCalculator.expects(:new).with(@table.identifier).returns(calculator)
      calculator.expects(:perform)
      @table.add(120.34)
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

        should 'add the difference when adding datapoints' do
          @table.add(120125)
          @table.add(120127)
          assert_equal 2, @table.last.value
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
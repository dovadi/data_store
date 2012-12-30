require File.expand_path '../test_helper', __FILE__

class TableTest < Test::Unit::TestCase

  context 'DataStore::table general' do

    setup do
      DataStore.configure do |config|
        config.database = ENV['DB'] || :postgres
      end
      DataStore::Connector.new.reset!

      @record = DataStore::Base.create(identifier:  1,
                                       type:        'gauge', 
                                       name:        'Electra',
                                       description: 'Actual usage of electra in the home',
                                       compression_schema: [5,6,10])
      @table = DataStore::Table.new(1)
      @table.reset!
    end

    should 'return the value of the identifier' do
      assert_equal 1, @table.identifier
    end

    should 'return the corresponding parent record' do
      assert_equal true, @table.parent.is_a?(DataStore::Base)
      assert_equal 1, @table.parent.identifier
    end

    should 'be able to reset the entire table' do
      @table.expects(:migrate).with(:down)
      @table.expects(:migrate).with(:up)
      @table.reset!
    end

    should 'have created the complete table' do
      assert_equal 0, DataStore::Base.db[:ds_1].count
      assert_equal 0, DataStore::Base.db[:ds_1_5].count
      assert_equal 0, DataStore::Base.db[:ds_1_30].count
      assert_equal 0, DataStore::Base.db[:ds_1_300].count
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

  end

end
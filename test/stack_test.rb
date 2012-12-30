require File.expand_path '../test_helper', __FILE__

class StackTest < Test::Unit::TestCase

  context 'DataStore::Stack general' do

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
      @stack = DataStore::Stack.new(1)
      @stack.reset!
    end

    should 'return the value of the identifier' do
      assert_equal 1, @stack.identifier
    end

    should 'return the corresponding parent record' do
      assert_equal true, @stack.parent.is_a?(DataStore::Base)
      assert_equal 1, @stack.parent.identifier
    end

    should 'be able to reset the entire stack' do
      @stack.expects(:migrate).with(:down)
      @stack.expects(:migrate).with(:up)
      @stack.reset!
    end

    should 'have created the complete stack' do
      assert_equal 0, DataStore::Base.db[:ds_1].count
      assert_equal 0, DataStore::Base.db[:ds_1_5].count
      assert_equal 0, DataStore::Base.db[:ds_1_30].count
      assert_equal 0, DataStore::Base.db[:ds_1_300].count
    end

    context 'adding datapoints' do

      setup do
        @stack.stubs(:calculate_average_values)
      end

      should 'push a datapoint to the stack' do
        @stack.push(120.34)
        assert_equal 1, @stack.count
      end

      should 'pop a datapoint from the stack' do
        @stack.push(120.34)
        @stack.push(120.38)
        assert_equal 120.38, @stack.pop.value
      end

      should 'return corresponding model' do
        @stack.push(123.45)
        assert_equal 123.45, @stack.model.find(value: 123.45).value
      end
    end

    should 'Trigger the average calculator after pushing a value' do
      calculator = mock
      DataStore::AverageCalculator.expects(:new).with(@stack.identifier).returns(calculator)
      calculator.expects(:perform)
      @stack.push(120.34)
    end

  end

end
require File.expand_path '../test_helper', __FILE__

class StackTest < Test::Unit::TestCase

  context 'DataStore::Stack general' do

    setup do
      DataStore.configuration.database = ENV['DB'] || :postgres
      DataStore::Connector.new.reset!
      @record = DataStore.model.create(identifier:  1,
                                       type:        'gauge', 
                                       name:        'Electra',
                                       description: 'Actual usage of electra in the home')
      @stack = DataStore::Stack.new(1)
      @stack.reset!
    end

    should 'return the value of the identifier' do
      assert_equal 1, @stack.identifier
    end

    should 'return the corresponding parent record' do
      assert_equal 1, @stack.parent.identifier
    end

    should 'be able to create the stack' do
      migration = mock
      DataStore.expects(:create_stack).with(:ds_1).returns(migration)
      migration.expects(:apply)
      @stack.create!
    end

    should 'be able to reset the entire stack' do
      DataStore::Stack.any_instance.expects(:drop!)
      migration = mock
      DataStore.expects(:create_stack).with(:ds_1).returns(migration)
      migration.expects(:apply)
      @stack.reset!
    end

    context 'adding datapoints' do

      setup do
        @stack.reset!
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

      should 'create the stack' do
        connector = DataStore::Connector.new
        assert_equal 0, connector.database[:ds_1].count
        connector.disconnect
      end

      should 'return corresponding model' do
        @stack.push(123.45)
        assert_equal 123.45, @stack.model.find(value: 123.45).value
      end

    end

  end

end
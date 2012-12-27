require File.expand_path '../test_helper', __FILE__

class DataStoreTest < Test::Unit::TestCase

  context 'DataStore configuration' do

    should 'have a configuration object' do
      assert_equal true, DataStore.configuration.is_a?(DataStore::Configuration)
    end

    should 'be able to define the configuration' do
      DataStore.configure do |config|
        config.database = ENV['DB'] || :mysql
      end
      assert_equal ENV['DB'] || :mysql, DataStore.configuration.database
    end

  end

  context 'DataStore::Base general' do

    setup do
      DataStore.configure do |config|
        config.database = ENV['DB'] || :mysql
      end
      DataStore::Connector.new.reset!
    end

    context 'with added behaviour through Sequel::Model' do

      setup do
        @record = DataStore::Base.create(identifier:  1,
                                         type:        'gauge', 
                                         name:        'Electra',
                                         description: 'Actual usage of electra in the home')
      end

      should 'be valid' do
        assert @record
      end

      should 'have added a record to the database' do
        assert_equal 1, DataStore::Base.count
      end

      should 'return all attibutes' do
        assert_equal 1, @record.identifier
        assert_equal 'gauge', @record.type
        assert_equal 'Electra', @record.name
        assert_equal 'Actual usage of electra in the home', @record.description
      end

      should 'have timestamps' do
        assert_equal true, @record.created_at.is_a?(Time)
        assert_equal true, @record.updated_at.is_a?(Time)
      end
      
      should 'create a record with a uniq identifier' do
        assert_raise 'Sequel::DatabaseError(<SQLite3::ConstraintException: column identifier is not unique>)' do
          DataStore::Base.create(identifier: 1, type: 'gauge', name: 'Electra')
        end
      end

      should 'be able to update a record' do
        @record.name = 'Gas'
        @record.save
        assert_equal 'Gas', DataStore::Base.order(:created_at).last.name
      end

    end

  end

end
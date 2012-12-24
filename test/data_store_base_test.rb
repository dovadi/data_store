require File.expand_path '../test_helper', __FILE__

class DataStoreBaseTest < Test::Unit::TestCase

  context 'DataStore::Base' do

    setup do
      DataStore.configure do |config|
        config.database = :sqlite3
      end
      drop_data_stores
      @database = Sequel.sqlite(File.expand_path('../../db/data_store.db', __FILE__))
    end

    should 'be valid' do
      assert DataStore::Base.new
    end

    should 'connect to a database' do
      assert_equal true, DataStore::Base.database.is_a?(Sequel::SQLite::Database)
    end


      context 'on create' do

        setup do
          @record = DataStore::Base.create(identifier: 1,
                                           type: 'gauge', 
                                           name: 'Electra',
                                           description: 'Actual usage of electra in the home')
        end

        should 'be valid' do
          assert @record
        end

        should 'have added a record to the database' do
          assert_equal 1, @database[:data_stores].count
        end

        should 'return all attibuts' do
          assert_equal 1, @record[:identifier]
          assert_equal 'gauge', @record[:type]
          assert_equal 'Electra', @record[:name]
          assert_equal 'Actual usage of electra in the home', @record[:description]
        end

        should 'have timestamps' do
          assert_equal true, @record[:created_at].is_a?(Time)
          assert_equal true, @record[:updated_at].is_a?(Time)
        end

        should 'create several records without trying to create a new table' do
          DataStore::Base.expects(:create_data_stores!).never
          DataStore::Base.create(identifier: 2, type: 'gauge', name: 'Electra')
          DataStore::Base.create(identifier: 3, type: 'gauge', name: 'Electra')
          assert_equal 3, @database[:data_stores].count
        end
        
        should 'create a record with a uniq identifier' do
          assert_raise 'Sequel::DatabaseError(<SQLite3::ConstraintException: column identifier is not unique>)' do
            DataStore::Base.create(identifier: 1, type: 'gauge', name: 'Electra')
          end
        end

      end

    teardown do
      drop_data_stores
    end

  end

end
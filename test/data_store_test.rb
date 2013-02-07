require File.expand_path '../test_helper', __FILE__

class DataStoreTest < Test::Unit::TestCase

  context 'DataStore configuration' do

    should 'have a configuration object' do
      assert_equal true, DataStore.configuration.is_a?(DataStore::Configuration)
    end

    should 'be able to define the configuration' do
      assert_equal ENV['DB'] || :postgres, DataStore.configuration.database
    end

  end

  context 'DataStore::Base general' do

    setup do
      DataStore::Connector.new.reset!
    end

    context 'with added behaviour through Sequel::Model' do

      setup do
        @record = DataStore::Base.create(identifier:         1,
                                         type:               'gauge', 
                                         name:               'Electra',
                                         description:        'Actual usage of electra in the home',
                                         compression_schema: [5,4,3])
      end

      should 'be valid' do
        assert @record
      end

      should 'have added a record to the database' do
        assert_equal 1, DataStore::Base.count
      end

      should 'have created the necessary tables' do
        assert_equal 0, DataStore::Base.db[:ds_1].count
        assert_equal 0, DataStore::Base.db[:ds_1_5].count
        assert_equal 0, DataStore::Base.db[:ds_1_20].count
        assert_equal 0, DataStore::Base.db[:ds_1_60].count
      end

      should 'return all table_names' do
        assert_equal [:ds_1, :ds_1_5, :ds_1_20, :ds_1_60], @record.table_names
      end

      should 'return its time_borders' do
        assert_equal [8000, 40000, 160000, 480000], @record.time_borders
      end

      should 'return its attributes' do
        record = DataStore::Base.order(:created_at).last
        assert_equal 1, record.identifier
        assert_equal 'gauge', record.type
        assert_equal 'Electra', record.name
        assert_equal 'Actual usage of electra in the home', record.description
        assert_equal [5,4,3], @record.compression_schema
      end

      should 'return default values if not set' do
        assert_equal 10, @record.frequency
        assert_equal 'double', @record.data_type
        assert_equal 800, @record.maximum_datapoints
      end

      should 'have timestamps' do
        assert @record.created_at
        assert @record.updated_at
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

    should 'create with the correct data type for value' do
      record = DataStore::Base.create(identifier: 2, type: 'gauge', name: 'Electra', data_type: 'integer')
      assert_equal :integer,Sequel::Model(DataStore::Base.db[:ds_2]).db_schema[:value][:type]
      record.destroy
    end

    context 'handling of database tables for the datapoints' do

      should 'create the necessary datapoint tables on create' do
        DataStore::Base.any_instance.expects(:drop_tables!)
        DataStore::Base.any_instance.expects(:create_tables!)
        DataStore::Base.create(identifier: 1, type: 'gauge', name: 'Electra')
      end

      should 'destroy the corresponding datapoint tables on destroy' do
        record = DataStore::Base.create(identifier: 1, type: 'gauge', name: 'Electra')
        record.destroy        
        assert_raise { DataStore::Base.db[:ds_1].count }
        assert_raise { DataStore::Base.db[:ds_5].count }
        assert_raise { DataStore::Base.db[:ds_20].count }
        assert_raise { DataStore::Base.db[:ds_60].count }
      end

    end

  end

end
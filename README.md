# DataStore

<a href='http://travis-ci.org/dovadi/data_store'>
![http://travis-ci.org/dovadi/data_store](https://secure.travis-ci.org/dovadi/data_store.png)
</a>

DataStore is designed to store real time data and manage the growth of your dataset by deciding the time period of your historical data. DataStore is tested with Ruby 1.9.3, Rubinius and JRuby and works with three database adapters Sqlite, Mysql and Postgresql.

## Installation

Add this line to your application's Gemfile:

    gem 'data_store'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install data_store

## Usage

### Install database adapter

Depending on the database you want to use and on which platform it is going to run, add the correct adapter to your projects Gemfile.

For MRI and Rubinius you can choose between:

    gem 'mysql2'
    gem 'sqlite3'
    gem 'pg'

For JRuby on of the following:

    gem 'jdbc-mysql'
    gem 'jdbc-sqlite3'
    gem 'jdbc-postgres'

### Configuration

    DataStore.configure do |config|
      config.prefix              = 'ds_'
      config.database            = :mysql
      config.compression_schema  = '[6,5,3]'
      config.data_type           = :double
      config.frequency           = 10
      config.maximum_datapoints  = 800
      config.log_file            = 'data_store.log'
      config.log_level           = Logger::INFO
    end

### Creation of a DataStore

    DataStore::Base.create(identifier: 1, type: 'gauge', name: 'Electra', description: 'Actual usage of electra in the home')

This will result in the creation of 4 tables,

    'ds_1'
    'ds_1_6'
    'ds_1_30'
    'ds_1_90'

with the following structure:

    id:      integer
    value:   double
    created: double #for unix timestamp

and a record to the main data_stores table with the corresponding field names

    id
    name
    description
    compression_schema
    frequency
    maximum_datapoints
    data_type

### Add a datapoint

    table = DataStore::Table.new(1)
    table.add(120.34)
    table.add(123.09)
    table.add(125.01)

### Fetching datapoints

    DataStore::Table.new(1).fetch(:from => (Time.now.utc - 3600).to_f, :till => Time.now.utc.to_f)

will result in an array of the maximum data points. An data point consists of an unix timestamp (UTC) and a value

    [[1352668356, 120], [1352678356, 123.09], [1352688356, 125.01]]

### Getting meta data of your data set

    DataStore::Table.new(1).parent

will return the corresponding record from the general data_stores table

or more specific count of the number of records

    DataStore::Table.new(1).count #=> 1249336

last record

    DataStore::Table.new(1).last

results

    #< @values={:id=>2, :value=>120.38, :created=>1356621436.67489}>

### Managing the size of your data set

### Export a data store (NOT implemented yet)

    DDataStore::Table.new(1).export
    
will result in a csv file with the name data_store_1.csv

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## Copyright

Copyright (c) 2013 Agile Dovadi BV - Frank Oxener.

See LICENSE.txt for further details.

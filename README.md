# DataStore

<a href='http://travis-ci.org/dovadi/data_store'>
![http://travis-ci.org/dovadi/data_store](https://secure.travis-ci.org/dovadi/data_store.png)
</a>

DataStore is designed to store real time data and manage the growth of your dataset by deciding the timeperiod of your historical data

## Installation

Add this line to your application's Gemfile:

    gem 'data_store'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install data_store

## Usage

### Configuration

    DataStore.configure do |config|
      config.prefix              = 'data_store'
      config.database            = :mysql
      config.compression_schema  = [6,5,3,4,4,3]
      config.data_type           = :float
      config.frequency           = 10
      config.maximum_datapoints  = 800
    end

### Creation of a DataStore

    DataStore::Base.create(identifier: 1, type: 'gauge', name: 'Electra', description: 'Actual usage of electra in the home')

This will result in the creation of 2 tables, one for the original data with the following structure named 'data_store_1:

    value:      float
    created_at: timestamp

and one for the average historical data with the following structure named 'data_store_1_history:

    value:      float
    created:    timestamp (float)
    timeslot:   integer

and a record to the main data_stores table with the corresponding field names

    id
    name
    description
    compression_schema
    frequency
    maximum_datapoints
    keep_details
    data_type

### Add a datapoint

    DataStore::Table.new(1).add(120.34)
    DataStore:Table.new(1).add(123.09)
    DataStore:Table.new(1).add(125.01)

### Fetching datapoints

    DataStore::Table.new(1).fetch(:from => (Time.now.utc - 3600).to_f, :till => Time.now.utc.to_f)

will result in an array of maximum 800 data points. An data point consists of an unix timestamp (UTC) and a value

    [[1352668356, 120], [1352678356, 123.09], [1352688356, 125.01]]

### Getting meta data of your data set

    DataStore::Table.new(1).parent

will return the correspondinf record from the general data_stores table

or more specific count of the number of records

    DataStore::Table.new(1).count #=> 1249336
    DataStore.new(1).history_count

last record

    DataStore::Table.new(1).pop

results

    #< @values={:id=>2, :value=>120.38, :created=>1356621436.67489}>

### Managing the size of your data set

### Export a data store

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

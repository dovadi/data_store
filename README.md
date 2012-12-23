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
      config.compression_factor  = 5
      config.data_type           = :float
      config.frequency           = 10
      config.maximum_datapoints  = 800
      config.keep_details        = 1.year
    end

### Creation of a DataStore

    DataStore.create(:identifier => 1, :type => :gauge, :name => 'Electra', :description => 'Actual usage of electra in the home')

This will result in the creation of 2 tables, one for the original data with the following structure named 'data_store_1:

    value:      float
    created_at: timestamp

and one for the average historical data with the following structure named 'data_store_1_history:

    value:      float
    created_at: timestamp
    timeslot:   integer

and a record to the main data_stores table with the corresponding field names

    id
    name
    description
    compression_factor
    frequency
    maximum_datapoints
    keep_details
    data_type

### Add a datapoint

    DataStore.new(1).store(120.34)
    DataStore.new(1).store(123.09)
    DataStore.new(1).store(125.01)

### Fetching datapoints

    DataStore.new(1).fetch(:from => (Time.zone.now - 1.hour).to_i, :till => Time.zone.now.to_i)

will result in an array of maximum 800 data points. An data point consists of an unix timestamp (UTC) and a value

    [[1352668356, 120], [1352678356, 123.09], [1352688356, 125.01]]

### Getting meta data of your data set

    DataStore.new(1).info

will return the following information

    :name => 'Electra'
    :description => 'Actual usage of electra in the home'

    :type => :gauge
    :data_type => :float
    :maximum_data_points => 800


or more specific count of the number of records

    DataStore.new(1).count #=> 1249336
    DataStore.new(1).history_count

last record

    DataStore.new(1).last

results

    [1352668356, 120.34]

### Managing the size of your data set

### Export a data store

    DataStore.new(1).export
    
will result in a csv file with the name data_store_1.csv

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

module DataStore

  class AverageCalculator

    include Celluloid

    TIMESTAMP_CORRECTION = 0.0001

    attr_reader :identifier, :base, :table_index, :table

    def initialize(table)
      @table       = table
      @identifier  = table.identifier
      @table_index = table.table_index
      @base        = Base.find(identifier: identifier)
    end

    # Calculate average value if needed
    # Average value is store dthrough an add call by a Table object
    # So the average calculator is called again recursively
    def perform
      if calculation_needed?
        average    = previous_average_record ? calculate! : dataset.avg(:value)
        table.type = :gauge
        table.add(average, table_index + 1, last[:created])
      end
    end

    private

    def calculate!
      last_time = previous_average_record[:created] + TIMESTAMP_CORRECTION
      dataset.where{created > last_time}.avg(:value)
    end

    def calculation_needed?
      return false if compression_finished
      if previous_average_record
        time_difference_since_last_calculation
        time_resolution   = table.parent.frequency * compression_factors[table_index]
        correction_factor = 0.1
        time_difference_since_last_calculation >= (time_resolution - (time_resolution * correction_factor)) 
      else
        dataset.count == base.compression_schema[table_index]
      end
    end

    def time_difference_since_last_calculation
      last[:created].round - previous_average_record[:created].round
    end

    def compression_factors
      array, factor = [], 1
      base.compression_schema.each do |compression|
        factor = (factor * compression)
        array << factor
      end
      array
    end

    def previous_average_record
      base.db[next_table].order(:created).last
    end

    def compression_finished
      table_index == base.compression_schema.size
    end

    def last
      dataset.order(:created).last
    end

    def dataset
      base.db[table_name]
    end

    def table_name
      if table_index == 0
        prefix.chop.to_sym
      else
        (prefix + compression_factors[table_index - 1].to_s).to_sym
      end
    end

    def next_table
      (prefix + compression_factors[table_index].to_s).to_sym
    end

    def prefix
      DataStore.configuration.prefix + identifier.to_s + '_'
    end
  end

end
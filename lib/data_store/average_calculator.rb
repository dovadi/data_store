module DataStore

  class AverageCalculator

    attr_reader :identifier, :base, :table_index, :table

    def initialize(table)
      @table       = table
      @identifier  = table.identifier
      @table_index = table.table_index
      @base        = Base.find(identifier: identifier)
    end

    def perform
      if last[:created] % compression_factors[table_index] == 0
        previous_id = last[:id] - compression_factors[table_index]
        average = dataset.where{id > previous_id}.avg(:value)
        table.add(average, table_index + 1) unless compression_finished
      end
    end

    def compression_schema
      base.compression_schema
    end

    def compression_factors
      array, factor = [], 1
      compression_schema.each do |compression|
        factor = (factor * compression)
        array << factor
      end
      array
    end

    private

    def compression_finished
      table_index + 1 == compression_schema.size
    end

    def last
      dataset.order(:created).last
    end

    def dataset
      @base.db[table_name]
    end

    def table_name
      if table_index == 0
        prefix.chop.to_sym
      else
        (prefix + compression_factors[table_index - 1].to_s).to_sym
      end
    end

    def prefix
      DataStore.configuration.prefix + identifier.to_s + '_'
    end
  end

end
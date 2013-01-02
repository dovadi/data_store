module DataStore

  class AverageCalculator

    attr_reader :identifier, :base, :table_index

    def initialize(identifier, table_index = 0)
      @identifier  = identifier
      @table_index = table_index
      @base        = Base.find(identifier: identifier)
    end

    def perform
      if last[:created] % compression_factors[table_index] == 0
        previous_id = last[:id] - compression_factors[table_index]
        dataset.where{id > previous_id}.avg(:value)
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

    def last
      dataset.order(:created).last
    end

    def dataset
      @base.db[table_name]
    end

    def table_name
      (DataStore.configuration.prefix + identifier.to_s).to_sym
    end
  end

end
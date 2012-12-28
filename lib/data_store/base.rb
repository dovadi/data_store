module DataStore

  class Base

    # Set the default values with the globally defined values
    #  * :compression_schema
    #  * :frequency
    #  * :maximum_datapoints
    #  * :data_type
    # See {Configuration}
    def before_save
      set_default_values  
    end

    # Convert serialized compression schema as a string back into the array object itself.
    # For example: "[5,4,3]" => [5,4,3]
    def compression_schema
      value = self.values[:compression_schema]
      eval(value) if value.is_a?(String) #convert string into array
    end

    private

    def default_values
      ['compression_schema', 'frequency', 'maximum_datapoints', 'data_type']
    end

    def set_default_values
      default_values.each do |variable|
        value = DataStore.configuration.send(variable)
        self.send(variable+ '=', value) if self.send(variable).nil?
      end
    end

  end

end
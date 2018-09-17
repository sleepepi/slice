# frozen_string_literal: true


# A subject object that contains a subset of values pulled from the database for
# that subject. The "o" is intentional to make these objects not seem to be
# actual ActiveRecord Subject instances.
module Engine
  class Sobject
    attr_accessor :subject_id, :values

    def initialize(subject_id)
      @subject_id = subject_id
      @values = {}
      # Ex: @values = { "age": 40, "bmi": 20.2, "free_text": "Once a day." }
    end

    def add_value(variable_name, value)
      @values[variable_name] = value
    end

    def get_value(variable_name)
      @values[variable_name]
    end

    def print_values
      puts "Subject: #{@subject_id}"
      puts "Values: #{@values}"
    end
  end
end

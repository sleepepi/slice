# frozen_string_literal: true


# A subject object that contains a subset of values pulled from the database for
# that subject. The "o" is intentional to make these objects not seem to be
# actual ActiveRecord Subject instances.
module Engine
  class Sobject
    attr_accessor :subject_id, :cells

    def initialize(subject_id)
      @subject_id = subject_id
      @cells = {}
      # Example:
      # @cells = {
      #   "age": [Cell(sheet_id: 1, value: 40), Cell(sheet_id: 2, value: 50)],
      #   "bmi": [Cell(sheet_id: 1, value: 20.2)],
      #   "free_text": [Cell(sheet_id: 1, value: "Once a day.")]
      # }
    end

    def get_cell(storage_name)
      @cells[storage_name]
    end

    def add_cell(storage_name, cell)
      @cells[storage_name] = cell
    end

    # def add_cell(storage_name, cell)
    #   @values[storage_name] ||= []
    #   @values[storage_name] << cell
    # end
  end
end

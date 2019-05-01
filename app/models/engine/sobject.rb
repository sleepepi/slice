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
      #   "age": [Cell(value: 40, seds: [Sed(sheet_id: 1, ...)]), Cell(value: 50, seds: [Sed(sheet_id: 2, ...)])],
      #   "bmi": [Cell(value: 20.2, seds: [Sed(sheet_id: 1, ...)])],
      #   "free_text": [Cell(value: "Once a day.", seds: [Sed(sheet_id: 1, ...)])]
      # }
    end

    def get_cells(storage_name)
      return [::Engine::Cell.new(nil)] if @cells[storage_name].blank?

      @cells[storage_name]
    end

    def initialize_cells(storage_name)
      @cells[storage_name] = []
    end

    def add_cell(storage_name, cell)
      @cells[storage_name] << cell
    end
  end
end

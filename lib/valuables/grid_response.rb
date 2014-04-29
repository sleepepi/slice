require 'valuables/default'

module Valuables

  class GridResponse < Default

    def name
      is_grid? ? grid_responses(:name) : super
    end

    def raw
      is_grid? ? grid_responses(:raw) : super
    end

    private

    def is_grid?
      @object.respond_to?('grids')
    end

    def grid_responses(raw_format = :raw)
      grid_responses = []
      (0..@object.grids.pluck(:position).max.to_i).each do |position|
        @object.variable.grid_variables.each do |grid_variable|
          grid = @object.grids.find_by_variable_id_and_position(grid_variable[:variable_id], position)
          grid_responses[position] ||= {}
          grid_responses[position][grid.variable.name] = grid.get_response(raw_format) if grid
        end
      end
      grid_responses.to_json
    end

  end

end

# frozen_string_literal: true

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
      all_grids = @object.grids.to_a

      (0..all_grids.collect(&:position).max.to_i).each do |position|
        @object.variable.grid_variables.each do |grid_variable|
          grid = all_grids.select{|g| g.variable_id == grid_variable[:variable_id].to_i and g.position == position}.first
          grid_responses[position] ||= {}
          grid_responses[position][grid.variable.name] = grid.get_response(raw_format) if grid
        end
      end
      grid_responses.to_json
    end
  end
end

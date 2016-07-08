# frozen_string_literal: true

module Pats
  module Categories
    class Default
      attr_reader :project

      def initialize(project)
        @project = project
      end

      def variable
        @variable ||= project.variables.find_by_name(variable_name)
      end

      def label
        'Default Category'
      end

      def subquery
        nil
      end

      def css_class
        nil
      end

      def inverse
        false
      end

      def variable_name
        nil
      end

      def model
        if variable && variable.variable_type == 'checkbox'
          Response
        else
          SheetVariable
        end
      end

      def select_sheet_ids
        model.where(variable: variable).where(subquery).select(:sheet_id)
      end
    end
  end
end

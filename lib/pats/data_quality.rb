# frozen_string_literal: true

require 'pats/core'
require 'pats/categories'
require 'pats/characteristics'

module Pats
  # Exports data quality statistics for subjects on PATS.
  module DataQuality
    include Pats::Core

    def data_quality_tables(project)
      tables = []
      tables << psg_overall_study_quality_table(project)
      tables
    end

    def psg_overall_study_quality_table(project)
      characteristic = Pats::Characteristics.for('psg-overall-study-quality', project)
      build_table(characteristic, psg_report_sheets(project))
    end
  end
end

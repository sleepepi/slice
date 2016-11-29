# frozen_string_literal: true

require 'pats/core'
require 'pats/categories'
require 'pats/characteristics'

module Pats
  # Exports demographics statistics for subjects on PATS.
  module Demographics
    include Pats::Core

    def demographics_screened(project)
      demographics(project, screened_sheets(project))
    end

    def demographics_consented(project)
      demographics(project, consented_sheets(project))
    end

    def demographics_eligible(project)
      demographics(project, eligible_sheets(project))
    end

    def demographics_randomized(project)
      demographics(project, randomized_sheets(project))
    end

    def filter_sheets_by_category(project, sheets, category_type)
      category = Pats::Categories.for(category_type, project)
      category.filter_sheets(sheets)
    end

    def female_sheets(project, sheets)
      filter_sheets_by_category(project, sheets, 'female')
    end

    def male_sheets(project, sheets)
      filter_sheets_by_category(project, sheets, 'male')
    end

    def black_race_sheets(project, sheets)
      filter_sheets_by_category(project, sheets, 'black-race')
    end

    def white_race_sheets(project, sheets)
      filter_sheets_by_category(project, sheets, 'white-race')
    end

    def american_indian_race_sheets(project, sheets)
      filter_sheets_by_category(project, sheets, 'american-indian-race')
    end

    def asian_race_sheets(project, sheets)
      filter_sheets_by_category(project, sheets, 'asian-race')
    end

    def hawaiian_race_sheets(project, sheets)
      filter_sheets_by_category(project, sheets, 'hawaiian-race')
    end

    def multiple_race_sheets(project, sheets)
      filter_sheets_by_category(project, sheets, 'multiple-race')
    end

    def age_3_to_4_sheets(project, sheets)
      filter_sheets_by_category(project, sheets, 'age-3to4')
    end

    def age_5_to_6_sheets(project, sheets)
      filter_sheets_by_category(project, sheets, 'age-5to6')
    end

    def age_7_plus_sheets(project, sheets)
      filter_sheets_by_category(project, sheets, 'age-7plus')
    end

    def demographics(project, sheets)
      tables = %w(age gender race ethnicity).collect do |characteristic_type|
        demographics_table(project, sheets, characteristic_type)
      end
      { tables: tables, extras: extras(project, sheets) }
    end

    def demographics_table(project, sheets, characteristic_type)
      characteristic = Pats::Characteristics.for(characteristic_type, project)
      build_table(characteristic, sheets)
    end

    def build_table(characteristic, sheets)
      {
        title: compute_title(characteristic),
        header: compute_header(characteristic),
        footer: [],
        rows: characteristic.categories.collect { |category| category.compute_row(sheets) }
      }
    end

    def compute_title(characteristic)
      "Demographics - #{characteristic.label} by Site"
    end

    def compute_header(characteristic)
      header = []
      header << ['', { text: 'Overall', colspan: 2 }] + characteristic.project.sites.collect { |s| { text: s.short_name, colspan: 2 } }
      header << [characteristic.label, { text: 'N', class: 'count' }, { text: '%', class: 'percent' }] + [{ text: 'N', class: 'count' }, { text: '%', class: 'percent' }] * characteristic.project.sites.count
      header
    end

    def extras(project, sheets)
      extras = { females: {}, males: {} }
      extras[:females][:total] = female_sheets(project, sheets).count
      extras[:females][:black] = black_race_sheets(project, female_sheets(project, sheets)).count
      extras[:females][:white] = white_race_sheets(project, female_sheets(project, sheets)).count
      extras[:females][:american_indian] = american_indian_race_sheets(project, female_sheets(project, sheets)).count
      extras[:females][:asian] = asian_race_sheets(project, female_sheets(project, sheets)).count
      extras[:females][:hawaiian] = hawaiian_race_sheets(project, female_sheets(project, sheets)).count
      extras[:females][:multiple] = multiple_race_sheets(project, female_sheets(project, sheets)).count
      extras[:males][:total] = male_sheets(project, sheets).count
      extras[:males][:black] = black_race_sheets(project, male_sheets(project, sheets)).count
      extras[:males][:white] = white_race_sheets(project, male_sheets(project, sheets)).count
      extras[:males][:american_indian] = american_indian_race_sheets(project, male_sheets(project, sheets)).count
      extras[:males][:asian] = asian_race_sheets(project, male_sheets(project, sheets)).count
      extras[:males][:hawaiian] = hawaiian_race_sheets(project, male_sheets(project, sheets)).count
      extras[:males][:multiple] = multiple_race_sheets(project, male_sheets(project, sheets)).count
      extras[:females][:age3to4] = age_3_to_4_sheets(project, female_sheets(project, sheets)).count
      extras[:females][:age5to6] = age_5_to_6_sheets(project, female_sheets(project, sheets)).count
      extras[:females][:age7plus] = age_7_plus_sheets(project, female_sheets(project, sheets)).count
      extras[:males][:age3to4] = age_3_to_4_sheets(project, male_sheets(project, sheets)).count
      extras[:males][:age5to6] = age_5_to_6_sheets(project, male_sheets(project, sheets)).count
      extras[:males][:age7plus] = age_7_plus_sheets(project, male_sheets(project, sheets)).count
      extras
    end
  end
end

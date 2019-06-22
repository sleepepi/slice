# frozen_string_literal: true

# Allows sheets to compute coverage.
module Coverageable
  extend ActiveSupport::Concern

  def out_of
    check_coverage
    "#{response_count} of #{total_response_count} #{total_response_count == 1 ? "question" : "questions"}"
  end

  # Sheets on empty designs should show as 100% complete.
  def compute_percent(rcount, trcount)
    return 100 if trcount.zero?

    (rcount * 100.0 / trcount).to_i
  end

  def non_hidden_variable_ids
    @non_hidden_variable_ids ||= begin
      variable_ids = []
      design.design_options.includes(:variable).each do |design_option|
        variable = design_option.variable
        variable_ids << variable.id if variable && show_design_option?(design_option.branching_logic)
      end
      variable_ids
    end
  end

  def non_hidden_responses
    sheet_variables.not_empty.where(variable_id: non_hidden_variable_ids).count
  end

  def non_hidden_total_responses
    non_hidden_variable_ids.count
  end

  def reset_coverage!
    update(response_count: nil, total_response_count: nil, percent: nil)
  end

  def check_coverage
    update_coverage! if response_count.nil? || total_response_count.nil? || percent.nil?
  end

  def update_coverage!
    if missing?
      rcount = 0
      trcount = 0
    else
      rcount = non_hidden_responses
      trcount = non_hidden_total_responses
    end
    pcount = compute_percent(rcount, trcount)
    update_columns(
      response_count: rcount,
      total_response_count: trcount,
      percent: pcount
    )
    subject_event&.update_coverage!
  end

  def coverage
    "coverage-#{(percent.to_i / 10) * 10}"
  end

  def color_ranges
    [
      { color: "#337ab7", minimum: 100 },
      { color: "#5cb85c", minimum: 80 },
      { color: "#f0ad4e", minimum: 60 },
      { color: "#f0ad4e", minimum: 40 },
      { color: "#d9534f", minimum: 1 }
    ]
  end

  def color
    color_ranges.each do |hash|
      return hash[:color] if percent.to_i >= hash[:minimum]
    end
    "#777777"
  end
end

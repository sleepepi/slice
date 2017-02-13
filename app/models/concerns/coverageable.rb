# frozen_string_literal: true

# Allows sheets to compute coverage.
module Coverageable
  extend ActiveSupport::Concern

  def out_of
    check_response_count_change
    "#{response_count} of #{total_response_count} #{total_response_count == 1 ? 'question' : 'questions'}"
  end

  def compute_percent(rcount, trcount)
    (rcount * 100.0 / trcount).to_i
  rescue
    nil
  end

  def non_hidden_variable_ids
    @non_hidden_variable_ids ||= begin
      variable_ids = []
      design.design_options.includes(:variable).each do |design_option|
        variable = design_option.variable
        if variable && show_design_option?(design_option.branching_logic)
          variable_ids << variable.id
        end
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

  def check_response_count_change
    update_response_count! if total_response_count.nil?
  end

  def update_response_count!
    rcount = non_hidden_responses
    trcount = non_hidden_total_responses
    pcount = compute_percent(rcount, trcount)
    update_columns(
      response_count: rcount,
      total_response_count: trcount,
      percent: pcount
    )
  end

  def coverage
    "coverage-#{(percent.to_i / 10) * 10}"
  end

  def color
    if percent.to_i == 100
      '#337ab7'
    elsif percent.to_i >= 80
      '#5cb85c'
    elsif percent.to_i >= 60
      '#f0ad4e'
    elsif percent.to_i >= 40
      '#f0ad4e'
    elsif percent.to_i >= 1
      '#d9534f'
    else
      '#777777'
    end
  end
end

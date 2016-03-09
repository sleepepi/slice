# frozen_string_literal: true

# Helps render the project menu
module ProjectsHelper
  SETUP_CONTROLLERS = %w(
    categories designs events variables domains randomization_schemes
    block_size_multipliers stratification_factors stratification_factor_options
    treatment_arms sites documents links posts contacts
  )

  def setup_path?
    (SETUP_CONTROLLERS.include?(params[:controller]) &&
      %w(randomize_subject randomize_subject_to_list).exclude?(params[:action])) ||
      params[:controller] == 'editor/projects'
  end
end

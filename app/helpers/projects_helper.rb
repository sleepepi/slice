# Helps render the project menu
module ProjectsHelper
  SETUP_CONTROLLERS = %w(
    categories designs events variables domains randomization_schemes
    block_size_multipliers stratification_factors stratification_factor_options
    treatment_arms projects
  )

  def setup_path?
    SETUP_CONTROLLERS.include?(params[:controller])
  end
end

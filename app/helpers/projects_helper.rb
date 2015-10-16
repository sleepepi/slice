# Helps render the project menu
module ProjectsHelper
  SETUP_CONTROLLERS = %w(
    categories designs events variables domains randomization_schemes
    block_size_multipliers stratification_factors stratification_factor_options
    treatment_arms sites documents links posts contacts
  )

  def setup_path?
    SETUP_CONTROLLERS.include?(params[:controller]) || (params[:controller] == 'projects' && %w(edit setup).include?(params[:action]))
  end
end

class ExportFormatter
  attr_reader :sheet_scope, :filename
  attr_reader :design_scope, :variables, :domains, :variable_ids
  attr_reader :grid_group_variables, :grid_variables, :grid_domains

  def initialize(sheet_scope, filename)
    @sheet_scope = sheet_scope
    @filename = filename

    setup_scoped_variables
  end

  def setup_scoped_variables
    @design_scope = Design.where(id: sheet_scope.pluck(:design_id)).order(:id)
    @variables = all_design_variables_without_grids
    @domains = Domain.where(id: @variables.collect{|v| v.domain_id}).order('name')

    # @variable_ids = Design.where(id: sheet_scope.pluck(:design_id)).order(:id).collect(&:variable_ids).flatten.uniq
    # @grid_group_variables = Variable.current.where(variable_type: 'grid', id: @variable_ids)
    @grid_group_variables = Variable.current.joins(:design_options).where(design_options: { design_id: sheet_scope.pluck(:design_id) }).where(variable_type: 'grid').order("design_options.design_id", "design_options.position")
    @grid_variables = []
    @grid_group_variables.each do |variable|
      variable.grid_variables.each do |grid_variable_hash|
        grid_variable = Variable.current.find_by_id(grid_variable_hash[:variable_id])
        @grid_variables << grid_variable if grid_variable
      end
    end
    @grid_domains = Domain.where(id: @grid_variables.collect{|v| v.domain_id}).order('name')
  end

  def all_design_variables_without_grids
    Variable.current.joins(:design_options).where(design_options: { design_id: @sheet_scope.select(:design_id) }).where.not(variable_type: 'grid').order("design_options.design_id", "design_options.position")
    # Design.where(id: @sheet_scope.pluck(:design_id)).order(:id).collect(&:variables).flatten.uniq.select{|v| v.variable_type != 'grid'}
  end

  def labels
    @labels ||= begin
      get_labels(@variables)
    end
  end

  def factors
    @factors ||= begin
      get_factors(@variables)
    end
  end

  def grid_labels
    @grid_labels ||= begin
      get_labels(@grid_variables)
    end
  end

  def grid_factors
    @grid_factors ||= begin
      get_factors(@grid_variables)
    end
  end

  def get_labels(variable_scope)
    variable_labels = []
    variable_scope.each do |variable|
      variable_labels << [variable.name, variable.display_name.gsub('"', '\"')]
      variable_labels += variable.shared_options.collect{|option| [variable.option_variable_name(option[:value]), "#{variable.display_name.gsub('"', '\"')} (#{option[:name].gsub('"', '\"')})"] } if variable.variable_type == 'checkbox'
    end
    variable_labels
  end

  def get_factors(variable_scope)
    variable_factors = []
    variable_scope.each do |variable|
      unless variable.shared_options.blank?
        unless variable.variable_type == 'checkbox'
          variable_factors << [variable.name, variable.shared_options]
        else
          variable_factors += variable.shared_options.collect{|option| [variable.option_variable_name(option[:value]), variable.shared_options] }
        end
      end
    end
    variable_factors
  end
end

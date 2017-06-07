# frozen_string_literal: true

class ExportFormatter
  attr_reader :sheet_scope, :filename
  attr_reader :design_scope, :variables, :domains, :variable_ids
  attr_reader :grid_group_variables, :grid_variables, :grid_domains
  attr_reader :sites, :events, :designs

  def initialize(sheet_scope, filename)
    @sheet_scope = sheet_scope
    @filename = filename

    setup_scoped_variables
  end

  def setup_scoped_variables
    @design_scope = Design.where(id: sheet_scope.select(:design_id)).order(:id)
    @sites = Site.where(id: sheet_scope.joins(:subject).select('subjects.site_id'))
    @events = Event.where(id: sheet_scope.joins(:subject_event).select('subject_events.event_id'))
    @designs = @design_scope
    @variables = all_design_variables_without_grids.uniq
    @domains = Domain.where(id: @variables.collect(&:domain_id)).order(:name)
    @grid_group_variables = Variable.current.joins(:design_options).where(design_options: { design_id: sheet_scope.pluck(:design_id) }).where(variable_type: 'grid').order('design_options.design_id', 'design_options.position').uniq
    @grid_variables = []
    @grid_group_variables.each do |variable|
      variable.child_variables.each do |child_variable|
        @grid_variables << child_variable
      end
    end
    @grid_domains = Domain.where(id: @grid_variables.collect{|v| v.domain_id}).order('name')
  end

  def all_design_variables_without_grids
    Variable.current.joins(:design_options)
            .where(design_options: { design_id: @sheet_scope.select(:design_id) })
            .where.not(variable_type: 'grid')
            .order('design_options.design_id', 'design_options.position')
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
      if variable.variable_type == 'checkbox'
        variable_labels += variable.domain_options.collect { |domain_option| [variable.option_variable_name(domain_option), "#{variable.display_name.gsub('"', '\"')} (#{domain_option.name.gsub('"', '\"')})"] }
      else
        variable_labels << [variable.name, variable.display_name.gsub('"', '\"')]
      end
    end
    variable_labels
  end

  def get_factors(variable_scope)
    variable_factors = []
    variable_scope.each do |variable|
      if variable.domain_options.present?
        if variable.variable_type == 'checkbox'
          variable_factors += variable.domain_options.collect { |domain_option| [variable.option_variable_name(domain_option), variable.domain_options] }
        else
          variable_factors << [variable.name, variable.domain_options]
        end
      end
    end
    variable_factors
  end
end

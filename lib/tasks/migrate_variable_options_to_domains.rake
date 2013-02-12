# bundle exec rake migrate_variable_options_to_domains
# bundle exec rake migrate_variable_options_to_domains RAILS_ENV=production

desc "Migrate Variable Options to domains"
task migrate_variable_options_to_domains: :environment do
  total_variables = Variable.current.count

  Variable.current.each_with_index do |variable, index|

    unless variable.options.blank? or variable.domain
      puts "Variable: #{index+1} of #{total_variables}: #{variable.options.size}"

      domain_name = if variable.project.domains.where(name: variable.name).size == 0
        variable.name
      else
        variable.name + "_2013_migration"
      end

      domain = variable.project.domains.new({ name: domain_name, description: "Domain created from existing variable options.", options: variable.options, user_id: variable.user_id })
      variable.update_attributes( domain_id: domain.id ) if domain.save
    end

  end

end

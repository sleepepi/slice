# frozen_string_literal: true

namespace :projects do
  desc 'Copy a project to a new blank project'
  task copy: :environment do
    project_id = ARGV[1].to_s.gsub('PROJECT=', '')
    project_orig = Project.current.find_by_param project_id
    if project_orig
      project_new = Project.create(name: "#{project_orig.name} COPY", user_id: project_orig.user_id)
      copy_project_users(project_orig, project_new)
      copy_designs(project_orig, project_new)
    else
      puts 'Project Not Found'
    end
  end
end

def copy_project_users(project_orig, project_new)
  project_orig.project_users.where.not(user_id: nil).each do |pu|
    project_new.project_users.create(
      user_id: pu.user_id,
      editor: pu.editor,
      creator_id: pu.creator_id,
      unblinded: pu.unblinded
    )
    puts "Added #{pu.user.name.colorize(:white)} as project #{pu.editor ? 'editor' : 'viewer'}"
  end
end

def copy_designs(project_orig, project_new)
  puts "Designs: #{project_orig.designs.count}"
  project_orig.designs.each do |d|
    project_new.designs.create(
      name: d.name,
      slug: d.slug,
      user_id: d.user_id
    )
    puts "Added #{d.name.colorize(:white)} design"
  end
end

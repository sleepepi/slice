# frozen_string_literal: true

namespace :variables do
  desc 'Update variable layout'
  task update_layout: :environment do
    Variable.where(display_name_visibility: 'invisible').update_all(display_name_visibility: 'gone')
  end
end

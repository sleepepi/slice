# Use to configure basic appearance of template
Contour.setup do |config|

  # Enter your application name here. The name will be displayed in the title of all pages, ex: AppName - PageTitle
  config.application_name = DEFAULT_APP_NAME

  # If you want to style your name using html you can do so here, ex: <b>App</b>Name
  # config.application_name_html = ''

  # Enter your application version here. Do not include a trailing backslash. Recommend using a predefined constant
  config.application_version = Slice::VERSION::STRING

  # Enter your application header background image here.
  config.header_background_image = ''

  # Enter your application header title image here.
  # config.header_title_image = ''

  # Enter the items you wish to see in the menu
  config.menu_items =
  [
    {
      name: 'Sign Up', display: 'not_signed_in', path: 'new_user_registration_path', position: 'right'
    },
    {
      name: 'image_tag(current_user.avatar_url(18, "blank"))+" "+current_user.name', eval: true, display: 'signed_in', path: 'settings_path', position: 'right',
      links: [{ name: "About Slice v#{Slice::VERSION::STRING}", path: 'about_path' },
              { divider: true },
              { header: 'Administrative', condition: 'current_user.system_admin?' },
              { name: 'Users', path: 'users_path', condition: 'current_user.system_admin?' },
              { divider: true, condition: 'current_user.system_admin?' },
              { header: 'current_user.email', eval: true },
              { html: 'Settings', path: 'settings_path' },
              { divider: true },
              { header: 'Recent' },
              { name: 'Activity', path: 'activity_path' },
              { divider: true },
              { name: 'Logout', path: 'destroy_user_session_path' }]
    },
    {
      name: 'current_user.all_favorite_projects.first.name', eval: true, display: 'signed_in', path: 'project_path(current_user.all_favorite_projects.first)', position: 'left',
      condition: 'current_user.all_favorite_projects.first',
      links: [{ header: 'Sheets' },
              { name: 'Create Sheet', path: 'new_project_sheet_path(current_user.all_favorite_projects.first)', condition: 'current_user.all_projects.pluck(:id).include?(current_user.all_favorite_projects.first.id)' },
              { name: 'View Sheets', path: 'project_sheets_path(current_user.all_favorite_projects.first)' },
              { divider: true, condition: 'current_user.all_projects.pluck(:id).include?(current_user.all_favorite_projects.first.id)' },
              { header: 'Designs', condition: 'current_user.all_projects.pluck(:id).include?(current_user.all_favorite_projects.first.id)' },
              { name: 'Create Design', path: 'new_project_design_path(current_user.all_favorite_projects.first)', condition: 'current_user.all_projects.pluck(:id).include?(current_user.all_favorite_projects.first.id)' },
              { name: 'View Designs', path: 'project_designs_path(current_user.all_favorite_projects.first)', condition: 'current_user.all_projects.pluck(:id).include?(current_user.all_favorite_projects.first.id)' },
              { divider: true },
              { header: 'Reports' },
              { name: 'Summary Report', path: 'report_project_path(current_user.all_favorite_projects.first)' },
              { name: 'Subject Report', path: 'subject_report_project_path(current_user.all_favorite_projects.first)' },
              { divider: true },
              { header: 'Data' },
              { name: 'Create Export', path: 'project_sheets_path(current_user.all_favorite_projects.first, e: "1")' },
              { name: '"View Exports#{" <span class=\'badge\'>#{current_user.unviewed_active_exports.where(project_id: current_user.all_favorite_projects.first.id).size}</span>" if current_user.unviewed_active_exports.where(project_id: current_user.all_favorite_projects.first.id).size > 0}".html_safe', eval: true, path: 'project_exports_path(current_user.all_favorite_projects.first)' },
              { divider: true },
              { header: 'Recent' },
              { name: 'Activity', path: 'activity_project_path(current_user.all_favorite_projects.first)' }]
    },
    {
      name: 'current_user.all_favorite_projects[1].name', eval: true, display: 'signed_in', path: 'project_path(current_user.all_favorite_projects[1])', position: 'left',
      condition: 'current_user.all_favorite_projects[1]',
      links: [{ header: 'Sheets' },
              { name: 'Create Sheet', path: 'new_project_sheet_path(current_user.all_favorite_projects[1])', condition: 'current_user.all_projects.pluck(:id).include?(current_user.all_favorite_projects[1].id)' },
              { name: 'View Sheets', path: 'project_sheets_path(current_user.all_favorite_projects[1])' },
              { divider: true, condition: 'current_user.all_projects.pluck(:id).include?(current_user.all_favorite_projects[1].id)' },
              { header: 'Designs', condition: 'current_user.all_projects.pluck(:id).include?(current_user.all_favorite_projects[1].id)' },
              { name: 'Create Design', path: 'new_project_design_path(current_user.all_favorite_projects[1])', condition: 'current_user.all_projects.pluck(:id).include?(current_user.all_favorite_projects[1].id)' },
              { name: 'View Designs', path: 'project_designs_path(current_user.all_favorite_projects[1])', condition: 'current_user.all_projects.pluck(:id).include?(current_user.all_favorite_projects[1].id)' },
              { divider: true },
              { header: 'Reports' },
              { name: 'Summary Report', path: 'report_project_path(current_user.all_favorite_projects[1])' },
              { name: 'Subject Report', path: 'subject_report_project_path(current_user.all_favorite_projects[1])' },
              { divider: true },
              { header: 'Data' },
              { name: 'Create Export', path: 'project_sheets_path(current_user.all_favorite_projects[1], e: "1")' },
              { name: '"View Exports#{" <span class=\'badge\'>#{current_user.unviewed_active_exports.where(project_id: current_user.all_favorite_projects[1].id).size}</span>" if current_user.unviewed_active_exports.where(project_id: current_user.all_favorite_projects[1].id).size > 0}".html_safe', eval: true, path: 'project_exports_path(current_user.all_favorite_projects[1])' },
              { divider: true },
              { header: 'Recent' },
              { name: 'Activity', path: 'activity_project_path(current_user.all_favorite_projects[1])' }]
    },
    {
      name: 'current_user.all_favorite_projects[2].name', eval: true, display: 'signed_in', path: 'project_path(current_user.all_favorite_projects[2])', position: 'left',
      condition: 'current_user.all_favorite_projects[2]',
      links: [{ header: 'Sheets' },
              { name: 'Create Sheet', path: 'new_project_sheet_path(current_user.all_favorite_projects[2])', condition: 'current_user.all_projects.pluck(:id).include?(current_user.all_favorite_projects[2].id)' },
              { name: 'View Sheets', path: 'project_sheets_path(current_user.all_favorite_projects[2])' },
              { divider: true, condition: 'current_user.all_projects.pluck(:id).include?(current_user.all_favorite_projects[2].id)' },
              { header: 'Designs', condition: 'current_user.all_projects.pluck(:id).include?(current_user.all_favorite_projects[2].id)' },
              { name: 'Create Design', path: 'new_project_design_path(current_user.all_favorite_projects[2])', condition: 'current_user.all_projects.pluck(:id).include?(current_user.all_favorite_projects[2].id)' },
              { name: 'View Designs', path: 'project_designs_path(current_user.all_favorite_projects[2])', condition: 'current_user.all_projects.pluck(:id).include?(current_user.all_favorite_projects[2].id)' },
              { divider: true },
              { header: 'Reports' },
              { name: 'Summary Report', path: 'report_project_path(current_user.all_favorite_projects[2])' },
              { name: 'Subject Report', path: 'subject_report_project_path(current_user.all_favorite_projects[2])' },
              { divider: true },
              { header: 'Data' },
              { name: 'Create Export', path: 'project_sheets_path(current_user.all_favorite_projects[2], e: "1")' },
              { name: '"View Exports#{" <span class=\'badge\'>#{current_user.unviewed_active_exports.where(project_id: current_user.all_favorite_projects[2].id).size}</span>" if current_user.unviewed_active_exports.where(project_id: current_user.all_favorite_projects[2].id).size > 0}".html_safe', eval: true, path: 'project_exports_path(current_user.all_favorite_projects[2])' },
              { divider: true },
              { header: 'Recent' },
              { name: 'Activity', path: 'activity_project_path(current_user.all_favorite_projects[2])' }]
    },
    # {
    #   name: 'Projects', display: 'signed_in', path: 'projects_path', position: 'left',
    #   links: [{ name: 'Create Project', path: 'new_project_path' }]
    # },
    # {
    #   name: 'Reports', display: 'signed_in', path: 'reports_path', position: 'left'
    # },
    # {
    #   name: '"Exports#{" <span class=\'badge badge-success\'>#{current_user.unviewed_active_exports.size}</span>" if current_user.unviewed_active_exports.size > 0}#{" <span class=\'badge badge-warning\'>#{current_user.unviewed_pending_exports.size}</span>" if current_user.unviewed_pending_exports.size > 0}".html_safe', eval: true, display: 'signed_in', path: 'exports_path', position: 'left'
    # },
    # {
    #   name: 'Designs', display: 'signed_in', path: 'designs_path', position: 'left', condition: 'current_user.all_viewable_projects.size > 0',
    #   links: [{ name: 'Create Design', path: 'new_design_path' }]
    # },
    # {
    #   name: 'Variables', display: 'signed_in', path: 'variables_path', position: 'left', condition: 'current_user.all_viewable_projects.size > 0',
    #   links: [{ name: 'Create Variable', path: 'new_variable_path' }]
    # }
  ]

  # Enter search bar information if you would like one [default none]:
  config.search_bar = {
    display: 'signed_in',
    id: 'global-search',
    path: 'search_path',
    placeholder: 'Search',
    position: 'right'
  }

  # Enter an address of a valid RSS Feed if you would like to see news on the sign in page.
  config.news_feed = 'https://sleepepi.partners.org/category/informatics/slice/feed/rss'

  # Enter the max number of items you want to see in the news feed.
  config.news_feed_items = 3

  # The following three parameters can be set as strings, which will rotate through the colors on a daily basis, selecting an index using (YearDay % ArraySize)

  # A string or array of strings that represent a CSS color code for generic link color
  # config.link_color = nil

  # A string or array of strings that represent a CSS color code for the body background color
  # config.body_background_color = nil

  # A string or array of strings that represent an image url for the body background image
  # config.body_background_image = nil

  # A hash where the key is a string in "month-day" format where values are a hash of the link_color, body_background_color and/or body_background_image
  # An example might be (April 1st), { "4-1" => { body_background_image: 'aprilfools.jpg' } }
  # Note the lack of leading zeros!
  # Special days take precendence over the rotating options given above
  # config.month_day = {}

  # An array of hashes that specify additional fields to add to the sign up form
  # An example might be [ { attribute: 'first_name', type: 'text_field' }, { attribute: 'last_name', type: 'text_field' } ]
  config.sign_up_fields = [ { attribute: 'first_name', type: 'text_field' }, { attribute: 'last_name', type: 'text_field' } ]

  # An array of text fields used to trick spam bots using the honeypot approach. These text fields will not be displayed to the user.
  # An example might be [ :url, :address, :contact, :comment ]
  config.spam_fields = [ :url, :address, :contact, :comment ]
end

# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `rails
# db:schema:load`. When creating a new database, `rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2019_03_26_211254) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "adverse_event_comments", force: :cascade do |t|
    t.bigint "project_id"
    t.bigint "adverse_event_id"
    t.bigint "user_id"
    t.text "description"
    t.string "comment_type"
    t.boolean "deleted", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["adverse_event_id"], name: "index_adverse_event_comments_on_adverse_event_id"
    t.index ["deleted"], name: "index_adverse_event_comments_on_deleted"
    t.index ["project_id"], name: "index_adverse_event_comments_on_project_id"
    t.index ["user_id"], name: "index_adverse_event_comments_on_user_id"
  end

  create_table "adverse_event_files", force: :cascade do |t|
    t.bigint "project_id"
    t.bigint "adverse_event_id"
    t.bigint "user_id"
    t.string "attachment"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["adverse_event_id"], name: "index_adverse_event_files_on_adverse_event_id"
    t.index ["project_id"], name: "index_adverse_event_files_on_project_id"
    t.index ["user_id"], name: "index_adverse_event_files_on_user_id"
  end

  create_table "adverse_event_reviews", force: :cascade do |t|
    t.bigint "adverse_event_id"
    t.string "name"
    t.text "comment"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["adverse_event_id"], name: "index_adverse_event_reviews_on_adverse_event_id"
  end

  create_table "adverse_event_users", force: :cascade do |t|
    t.bigint "adverse_event_id"
    t.bigint "user_id"
    t.datetime "last_viewed_at"
    t.index ["adverse_event_id", "user_id"], name: "index_adverse_event_users_on_adverse_event_id_and_user_id", unique: true
  end

  create_table "adverse_events", force: :cascade do |t|
    t.bigint "project_id"
    t.bigint "user_id"
    t.bigint "subject_id"
    t.text "description"
    t.date "adverse_event_date"
    t.boolean "closed", default: false, null: false
    t.boolean "deleted", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "authentication_token"
    t.integer "number"
    t.index ["authentication_token"], name: "index_adverse_events_on_authentication_token", unique: true
    t.index ["closed"], name: "index_adverse_events_on_closed"
    t.index ["deleted"], name: "index_adverse_events_on_deleted"
    t.index ["number"], name: "index_adverse_events_on_number"
    t.index ["project_id"], name: "index_adverse_events_on_project_id"
    t.index ["subject_id"], name: "index_adverse_events_on_subject_id"
    t.index ["user_id"], name: "index_adverse_events_on_user_id"
  end

  create_table "ae_adverse_event_teams", force: :cascade do |t|
    t.bigint "project_id"
    t.bigint "ae_adverse_event_id"
    t.bigint "ae_team_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "team_review_completed_at"
    t.index ["ae_adverse_event_id", "ae_team_id"], name: "idx_adverse_event_team", unique: true
    t.index ["project_id"], name: "index_ae_adverse_event_teams_on_project_id"
    t.index ["team_review_completed_at"], name: "index_ae_adverse_event_teams_on_team_review_completed_at"
  end

  create_table "ae_adverse_events", force: :cascade do |t|
    t.bigint "project_id"
    t.bigint "user_id"
    t.bigint "subject_id"
    t.integer "number"
    t.text "description"
    t.datetime "closed_at"
    t.bigint "closer_id"
    t.boolean "deleted", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "reported_at"
    t.datetime "sent_for_review_at"
    t.index ["closed_at"], name: "index_ae_adverse_events_on_closed_at"
    t.index ["closer_id"], name: "index_ae_adverse_events_on_closer_id"
    t.index ["deleted"], name: "index_ae_adverse_events_on_deleted"
    t.index ["number"], name: "index_ae_adverse_events_on_number", unique: true
    t.index ["project_id"], name: "index_ae_adverse_events_on_project_id"
    t.index ["sent_for_review_at"], name: "index_ae_adverse_events_on_sent_for_review_at"
    t.index ["subject_id"], name: "index_ae_adverse_events_on_subject_id"
    t.index ["user_id"], name: "index_ae_adverse_events_on_user_id"
  end

  create_table "ae_assignments", force: :cascade do |t|
    t.bigint "project_id"
    t.bigint "ae_adverse_event_id"
    t.bigint "ae_team_id"
    t.bigint "manager_id"
    t.bigint "reviewer_id"
    t.datetime "review_completed_at"
    t.datetime "review_unassigned_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "ae_team_pathway_id"
    t.boolean "principal", default: false, null: false
    t.boolean "deleted", default: false, null: false
    t.index ["ae_adverse_event_id", "ae_team_id", "ae_team_pathway_id", "reviewer_id", "principal"], name: "idx_team_assignment_pathway", unique: true
    t.index ["deleted"], name: "index_ae_assignments_on_deleted"
    t.index ["manager_id"], name: "index_ae_assignments_on_manager_id"
    t.index ["principal"], name: "index_ae_assignments_on_principal"
    t.index ["project_id"], name: "index_ae_assignments_on_project_id"
    t.index ["review_completed_at"], name: "index_ae_assignments_on_review_completed_at"
    t.index ["review_unassigned_at"], name: "index_ae_assignments_on_review_unassigned_at"
  end

  create_table "ae_designments", force: :cascade do |t|
    t.bigint "project_id"
    t.bigint "design_id"
    t.string "role"
    t.bigint "ae_team_id"
    t.bigint "ae_team_pathway_id"
    t.integer "position"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["ae_team_id"], name: "index_ae_designments_on_ae_team_id"
    t.index ["ae_team_pathway_id"], name: "index_ae_designments_on_ae_team_pathway_id"
    t.index ["design_id"], name: "index_ae_designments_on_design_id"
    t.index ["position"], name: "index_ae_designments_on_position"
    t.index ["project_id"], name: "index_ae_designments_on_project_id"
    t.index ["role"], name: "index_ae_designments_on_role"
  end

  create_table "ae_documents", force: :cascade do |t|
    t.bigint "project_id"
    t.bigint "ae_adverse_event_id"
    t.bigint "user_id"
    t.string "file"
    t.string "filename"
    t.string "content_type"
    t.bigint "byte_size", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["ae_adverse_event_id"], name: "index_ae_documents_on_ae_adverse_event_id"
    t.index ["byte_size"], name: "index_ae_documents_on_byte_size"
    t.index ["content_type"], name: "index_ae_documents_on_content_type"
    t.index ["project_id"], name: "index_ae_documents_on_project_id"
    t.index ["user_id"], name: "index_ae_documents_on_user_id"
  end

  create_table "ae_info_requests", force: :cascade do |t|
    t.bigint "project_id"
    t.bigint "ae_adverse_event_id"
    t.bigint "user_id"
    t.bigint "ae_team_id"
    t.text "comment"
    t.datetime "resolved_at"
    t.bigint "resolver_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["ae_adverse_event_id"], name: "index_ae_info_requests_on_ae_adverse_event_id"
    t.index ["ae_team_id"], name: "index_ae_info_requests_on_ae_team_id"
    t.index ["project_id"], name: "index_ae_info_requests_on_project_id"
    t.index ["resolved_at"], name: "index_ae_info_requests_on_resolved_at"
    t.index ["resolver_id"], name: "index_ae_info_requests_on_resolver_id"
    t.index ["user_id"], name: "index_ae_info_requests_on_user_id"
  end

  create_table "ae_log_entries", force: :cascade do |t|
    t.bigint "project_id"
    t.bigint "ae_adverse_event_id"
    t.bigint "user_id"
    t.bigint "ae_team_id"
    t.string "entry_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["ae_adverse_event_id"], name: "index_ae_log_entries_on_ae_adverse_event_id"
    t.index ["ae_team_id"], name: "index_ae_log_entries_on_ae_team_id"
    t.index ["project_id"], name: "index_ae_log_entries_on_project_id"
    t.index ["user_id"], name: "index_ae_log_entries_on_user_id"
  end

  create_table "ae_log_entry_attachments", force: :cascade do |t|
    t.bigint "ae_log_entry_id"
    t.bigint "attachment_id"
    t.string "attachment_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["ae_log_entry_id", "attachment_id"], name: "idx_log_attachment", unique: true
    t.index ["attachment_type"], name: "index_ae_log_entry_attachments_on_attachment_type"
  end

  create_table "ae_review_admins", force: :cascade do |t|
    t.bigint "project_id"
    t.bigint "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["project_id", "user_id"], name: "index_ae_review_admins_on_project_id_and_user_id", unique: true
  end

  create_table "ae_sheets", force: :cascade do |t|
    t.bigint "project_id"
    t.bigint "ae_adverse_event_id"
    t.bigint "sheet_id"
    t.string "role"
    t.bigint "ae_team_id"
    t.bigint "ae_assignment_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["ae_adverse_event_id", "sheet_id"], name: "index_ae_sheets_on_ae_adverse_event_id_and_sheet_id", unique: true
    t.index ["ae_assignment_id"], name: "index_ae_sheets_on_ae_assignment_id"
    t.index ["ae_team_id"], name: "index_ae_sheets_on_ae_team_id"
    t.index ["project_id"], name: "index_ae_sheets_on_project_id"
    t.index ["role"], name: "index_ae_sheets_on_role"
  end

  create_table "ae_team_members", force: :cascade do |t|
    t.bigint "project_id"
    t.bigint "ae_team_id"
    t.bigint "user_id"
    t.boolean "manager", default: false, null: false
    t.boolean "reviewer", default: false, null: false
    t.boolean "viewer", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "principal_reviewer", default: false, null: false
    t.index ["ae_team_id", "user_id"], name: "index_ae_team_members_on_ae_team_id_and_user_id", unique: true
    t.index ["manager"], name: "index_ae_team_members_on_manager"
    t.index ["principal_reviewer"], name: "index_ae_team_members_on_principal_reviewer"
    t.index ["project_id"], name: "index_ae_team_members_on_project_id"
    t.index ["reviewer"], name: "index_ae_team_members_on_reviewer"
    t.index ["viewer"], name: "index_ae_team_members_on_viewer"
  end

  create_table "ae_team_pathways", force: :cascade do |t|
    t.bigint "project_id"
    t.bigint "ae_team_id"
    t.string "name"
    t.boolean "deleted", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["ae_team_id"], name: "index_ae_team_pathways_on_ae_team_id"
    t.index ["deleted"], name: "index_ae_team_pathways_on_deleted"
    t.index ["project_id"], name: "index_ae_team_pathways_on_project_id"
  end

  create_table "ae_teams", force: :cascade do |t|
    t.bigint "project_id"
    t.string "name"
    t.string "slug"
    t.boolean "deleted", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "short_name"
    t.integer "pathways_count", default: 0, null: false
    t.index ["deleted"], name: "index_ae_teams_on_deleted"
    t.index ["pathways_count"], name: "index_ae_teams_on_pathways_count"
    t.index ["project_id", "slug"], name: "index_ae_teams_on_project_id_and_slug", unique: true
  end

  create_table "authentications", force: :cascade do |t|
    t.bigint "user_id"
    t.string "provider", limit: 255
    t.string "uid", limit: 255
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_authentications_on_user_id"
  end

  create_table "block_size_multipliers", force: :cascade do |t|
    t.bigint "project_id"
    t.bigint "user_id"
    t.bigint "randomization_scheme_id"
    t.integer "value", default: 0, null: false
    t.integer "allocation", default: 0, null: false
    t.boolean "deleted", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["project_id"], name: "index_block_size_multipliers_on_project_id"
    t.index ["randomization_scheme_id", "deleted"], name: "index_bsmultipliers_on_randomization_scheme_id_and_deleted"
    t.index ["randomization_scheme_id"], name: "index_block_size_multipliers_on_randomization_scheme_id"
    t.index ["user_id"], name: "index_block_size_multipliers_on_user_id"
  end

  create_table "categories", force: :cascade do |t|
    t.bigint "project_id"
    t.bigint "user_id"
    t.boolean "use_for_adverse_events", default: false, null: false
    t.string "name"
    t.string "slug"
    t.integer "position", default: 0, null: false
    t.text "description"
    t.boolean "deleted", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["deleted"], name: "index_categories_on_deleted"
    t.index ["project_id"], name: "index_categories_on_project_id"
    t.index ["user_id"], name: "index_categories_on_user_id"
  end

  create_table "checks", force: :cascade do |t|
    t.bigint "project_id"
    t.bigint "user_id"
    t.string "name"
    t.string "slug"
    t.text "description"
    t.boolean "archived", default: false, null: false
    t.boolean "deleted", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "message"
    t.datetime "last_run_at"
    t.text "expression"
    t.index ["archived"], name: "index_checks_on_archived"
    t.index ["deleted"], name: "index_checks_on_deleted"
    t.index ["last_run_at"], name: "index_checks_on_last_run_at"
    t.index ["project_id", "slug"], name: "index_checks_on_project_id_and_slug", unique: true
    t.index ["user_id"], name: "index_checks_on_user_id"
  end

  create_table "comments", force: :cascade do |t|
    t.text "description"
    t.bigint "user_id"
    t.bigint "sheet_id"
    t.boolean "deleted", default: false, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["deleted"], name: "index_comments_on_deleted"
    t.index ["sheet_id"], name: "index_comments_on_sheet_id"
    t.index ["user_id"], name: "index_comments_on_user_id"
  end

  create_table "cubes", force: :cascade do |t|
    t.bigint "tray_id"
    t.integer "position"
    t.text "text"
    t.text "description"
    t.string "cube_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["tray_id"], name: "index_cubes_on_tray_id"
  end

  create_table "design_images", force: :cascade do |t|
    t.bigint "project_id"
    t.bigint "design_id"
    t.bigint "user_id"
    t.string "file"
    t.string "filename"
    t.bigint "byte_size", default: 0, null: false
    t.string "content_type"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "number"
    t.index ["byte_size"], name: "index_design_images_on_byte_size"
    t.index ["content_type"], name: "index_design_images_on_content_type"
    t.index ["design_id", "number"], name: "index_design_images_on_design_id_and_number", unique: true
    t.index ["design_id"], name: "index_design_images_on_design_id"
    t.index ["project_id"], name: "index_design_images_on_project_id"
    t.index ["user_id"], name: "index_design_images_on_user_id"
  end

  create_table "design_options", force: :cascade do |t|
    t.bigint "design_id"
    t.bigint "variable_id"
    t.bigint "section_id"
    t.integer "position", default: 0, null: false
    t.string "requirement"
    t.text "branching_logic"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["design_id", "section_id"], name: "index_design_options_on_design_id_and_section_id", unique: true
    t.index ["design_id", "variable_id"], name: "index_design_options_on_design_id_and_variable_id", unique: true
    t.index ["design_id"], name: "index_design_options_on_design_id"
    t.index ["section_id"], name: "index_design_options_on_section_id"
    t.index ["variable_id"], name: "index_design_options_on_variable_id"
  end

  create_table "design_prints", force: :cascade do |t|
    t.bigint "design_id"
    t.string "language"
    t.boolean "outdated", default: true, null: false
    t.string "file"
    t.bigint "file_size", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["design_id", "language"], name: "index_design_prints_on_design_id_and_language", unique: true
  end

  create_table "designs", force: :cascade do |t|
    t.string "name", limit: 255
    t.bigint "project_id"
    t.bigint "user_id"
    t.boolean "deleted", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "updater_id"
    t.boolean "publicly_available", default: false, null: false
    t.string "survey_slug", limit: 255
    t.string "redirect_url", limit: 255
    t.boolean "show_site", default: false, null: false
    t.bigint "category_id"
    t.boolean "only_unblinded", default: false, null: false
    t.boolean "ignore_auto_lock", default: false, null: false
    t.string "short_name"
    t.boolean "repeated", default: false, null: false
    t.integer "variables_count", default: 0, null: false
    t.boolean "notifications_enabled", default: false, null: false
    t.boolean "translated", default: false, null: false
    t.string "slug"
    t.datetime "pdf_cache_busted_at"
    t.datetime "coverage_cache_busted_at"
    t.index ["category_id"], name: "index_designs_on_category_id"
    t.index ["deleted"], name: "index_designs_on_deleted"
    t.index ["project_id", "slug"], name: "index_designs_on_project_id_and_slug", unique: true
    t.index ["project_id"], name: "index_designs_on_project_id"
    t.index ["survey_slug"], name: "index_designs_on_survey_slug", unique: true
    t.index ["user_id"], name: "index_designs_on_user_id"
    t.index ["variables_count"], name: "index_designs_on_variables_count"
  end

  create_table "domain_options", force: :cascade do |t|
    t.bigint "domain_id"
    t.string "name"
    t.string "value"
    t.text "description"
    t.bigint "site_id"
    t.boolean "missing_code", default: false, null: false
    t.boolean "archived", default: false, null: false
    t.integer "position"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "mutually_exclusive", default: false, null: false
    t.index ["archived"], name: "index_domain_options_on_archived"
    t.index ["domain_id", "value"], name: "index_domain_options_on_domain_id_and_value", unique: true
    t.index ["missing_code"], name: "index_domain_options_on_missing_code"
    t.index ["position"], name: "index_domain_options_on_position"
    t.index ["site_id"], name: "index_domain_options_on_site_id"
  end

  create_table "domains", force: :cascade do |t|
    t.string "name", limit: 255
    t.text "description"
    t.bigint "user_id"
    t.bigint "project_id"
    t.boolean "deleted", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "display_name", limit: 255
    t.integer "variables_count", default: 0, null: false
    t.index ["deleted"], name: "index_domains_on_deleted"
    t.index ["project_id"], name: "index_domains_on_project_id"
    t.index ["user_id"], name: "index_domains_on_user_id"
    t.index ["variables_count"], name: "index_domains_on_variables_count"
  end

  create_table "engine_runs", force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "project_id"
    t.string "expression"
    t.integer "runtime_ms"
    t.integer "subjects_count", default: 0, null: false
    t.integer "sheets_count", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["project_id"], name: "index_engine_runs_on_project_id"
    t.index ["runtime_ms"], name: "index_engine_runs_on_runtime_ms"
    t.index ["sheets_count"], name: "index_engine_runs_on_sheets_count"
    t.index ["subjects_count"], name: "index_engine_runs_on_subjects_count"
    t.index ["user_id"], name: "index_engine_runs_on_user_id"
  end

  create_table "event_designs", force: :cascade do |t|
    t.bigint "event_id"
    t.bigint "design_id"
    t.integer "position", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "handoff_enabled", default: false, null: false
    t.string "requirement", default: "always", null: false
    t.bigint "conditional_event_id"
    t.bigint "conditional_design_id"
    t.bigint "conditional_variable_id"
    t.string "conditional_value"
    t.string "conditional_operator", default: "=", null: false
    t.string "duplicates", default: "highlight", null: false
    t.index ["conditional_design_id"], name: "index_event_designs_on_conditional_design_id"
    t.index ["conditional_event_id"], name: "index_event_designs_on_conditional_event_id"
    t.index ["conditional_variable_id"], name: "index_event_designs_on_conditional_variable_id"
    t.index ["design_id"], name: "index_event_designs_on_design_id"
    t.index ["event_id"], name: "index_event_designs_on_event_id"
    t.index ["handoff_enabled"], name: "index_event_designs_on_handoff_enabled"
    t.index ["requirement"], name: "index_event_designs_on_requirement"
  end

  create_table "events", force: :cascade do |t|
    t.string "name", limit: 255
    t.text "description"
    t.bigint "project_id"
    t.bigint "user_id"
    t.boolean "deleted", default: false, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean "archived", default: false, null: false
    t.integer "position"
    t.string "slug"
    t.boolean "only_unblinded", default: false, null: false
    t.index ["archived"], name: "index_events_on_archived"
    t.index ["deleted"], name: "index_events_on_deleted"
    t.index ["only_unblinded"], name: "index_events_on_only_unblinded"
    t.index ["position"], name: "index_events_on_position"
    t.index ["project_id"], name: "index_events_on_project_id"
    t.index ["user_id"], name: "index_events_on_user_id"
  end

  create_table "expected_randomizations", force: :cascade do |t|
    t.bigint "randomization_scheme_id"
    t.bigint "site_id"
    t.string "expected"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["randomization_scheme_id", "site_id"], name: "expected_randomizations_index", unique: true
  end

  create_table "exports", force: :cascade do |t|
    t.string "name", limit: 255
    t.boolean "include_files", default: false, null: false
    t.string "status", limit: 255, default: "pending", null: false
    t.string "file", limit: 255
    t.bigint "user_id"
    t.bigint "project_id"
    t.boolean "deleted", default: false, null: false
    t.datetime "file_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "details"
    t.boolean "include_xls", default: false, null: false
    t.boolean "include_csv_labeled", default: false, null: false
    t.boolean "include_csv_raw", default: false, null: false
    t.boolean "include_pdf", default: false, null: false
    t.boolean "include_data_dictionary", default: false, null: false
    t.boolean "include_sas", default: false, null: false
    t.integer "steps_completed", default: 0, null: false
    t.integer "total_steps", default: 0, null: false
    t.integer "sheet_ids_count", default: 0, null: false
    t.boolean "include_r", default: false, null: false
    t.integer "variables_count", default: 0, null: false
    t.boolean "include_adverse_events", default: false, null: false
    t.integer "grid_variables_count", default: 0, null: false
    t.boolean "include_randomizations", default: false, null: false
    t.string "filters"
    t.bigint "file_size", default: 0, null: false
    t.boolean "include_medications", default: false, null: false
    t.index ["deleted"], name: "index_exports_on_deleted"
    t.index ["file_size"], name: "index_exports_on_file_size"
    t.index ["project_id"], name: "index_exports_on_project_id"
    t.index ["status"], name: "index_exports_on_status"
    t.index ["user_id"], name: "index_exports_on_user_id"
  end

  create_table "faces", force: :cascade do |t|
    t.bigint "cube_id"
    t.integer "position"
    t.text "text"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["cube_id"], name: "index_faces_on_cube_id"
  end

  create_table "grid_variables", force: :cascade do |t|
    t.bigint "project_id"
    t.bigint "parent_variable_id"
    t.bigint "child_variable_id"
    t.integer "position"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["parent_variable_id", "child_variable_id"], name: "parent_child_variable_index", unique: true
    t.index ["position"], name: "index_grid_variables_on_position"
    t.index ["project_id"], name: "index_grid_variables_on_project_id"
  end

  create_table "grids", force: :cascade do |t|
    t.bigint "sheet_variable_id"
    t.bigint "variable_id"
    t.text "value"
    t.text "response_file"
    t.bigint "user_id"
    t.integer "position"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "domain_option_id"
    t.index ["domain_option_id"], name: "index_grids_on_domain_option_id"
    t.index ["sheet_variable_id"], name: "index_grids_on_sheet_variable_id"
    t.index ["user_id"], name: "index_grids_on_user_id"
    t.index ["variable_id"], name: "index_grids_on_variable_id"
  end

  create_table "handoffs", force: :cascade do |t|
    t.string "token"
    t.bigint "user_id"
    t.bigint "project_id"
    t.bigint "subject_event_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["project_id", "subject_event_id"], name: "index_handoffs_on_project_id_and_subject_event_id", unique: true
    t.index ["project_id", "token"], name: "index_handoffs_on_project_id_and_token", unique: true
    t.index ["project_id"], name: "index_handoffs_on_project_id"
    t.index ["subject_event_id"], name: "index_handoffs_on_subject_event_id"
    t.index ["user_id"], name: "index_handoffs_on_user_id"
  end

  create_table "invites", force: :cascade do |t|
    t.bigint "project_id"
    t.bigint "inviter_id"
    t.string "email"
    t.string "role"
    t.string "subgroup_type"
    t.bigint "subgroup_id"
    t.datetime "email_sent_at"
    t.datetime "accepted_at"
    t.datetime "declined_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["accepted_at"], name: "index_invites_on_accepted_at"
    t.index ["declined_at"], name: "index_invites_on_declined_at"
    t.index ["email"], name: "index_invites_on_email"
    t.index ["inviter_id"], name: "index_invites_on_inviter_id"
    t.index ["project_id"], name: "index_invites_on_project_id"
    t.index ["subgroup_id"], name: "index_invites_on_subgroup_id"
    t.index ["subgroup_type"], name: "index_invites_on_subgroup_type"
  end

  create_table "list_options", force: :cascade do |t|
    t.bigint "project_id"
    t.bigint "randomization_scheme_id"
    t.bigint "list_id"
    t.bigint "option_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["list_id", "option_id"], name: "index_list_options_on_list_id_and_option_id"
    t.index ["list_id"], name: "index_list_options_on_list_id"
    t.index ["option_id"], name: "index_list_options_on_option_id"
    t.index ["project_id"], name: "index_list_options_on_project_id"
    t.index ["randomization_scheme_id"], name: "index_list_options_on_randomization_scheme_id"
  end

  create_table "lists", force: :cascade do |t|
    t.bigint "project_id"
    t.bigint "randomization_scheme_id"
    t.bigint "user_id"
    t.boolean "deleted", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "extra_options"
    t.index ["deleted"], name: "index_lists_on_deleted"
    t.index ["project_id"], name: "index_lists_on_project_id"
    t.index ["randomization_scheme_id", "deleted"], name: "index_lists_on_randomization_scheme_id_and_deleted"
    t.index ["randomization_scheme_id"], name: "index_lists_on_randomization_scheme_id"
    t.index ["user_id"], name: "index_lists_on_user_id"
  end

  create_table "medication_templates", force: :cascade do |t|
    t.bigint "project_id"
    t.string "name"
    t.boolean "mark_for_deletion", default: false, null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["mark_for_deletion"], name: "index_medication_templates_on_mark_for_deletion"
    t.index ["project_id", "name"], name: "index_medication_templates_on_project_id_and_name", unique: true
  end

  create_table "medication_values", force: :cascade do |t|
    t.bigint "project_id"
    t.bigint "medication_variable_id"
    t.bigint "subject_id"
    t.bigint "medication_id"
    t.string "value"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["medication_variable_id", "medication_id"], name: "index_med_values_on_medication_and_med_variable", unique: true
    t.index ["project_id"], name: "index_medication_values_on_project_id"
    t.index ["subject_id"], name: "index_medication_values_on_subject_id"
  end

  create_table "medication_variables", force: :cascade do |t|
    t.bigint "project_id"
    t.string "name"
    t.text "autocomplete_values"
    t.boolean "deleted", default: false, null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "position"
    t.index ["deleted"], name: "index_medication_variables_on_deleted"
    t.index ["project_id"], name: "index_medication_variables_on_project_id"
  end

  create_table "medications", force: :cascade do |t|
    t.bigint "project_id"
    t.bigint "subject_id"
    t.integer "position"
    t.string "name"
    t.string "start_date_fuzzy"
    t.string "stop_date_fuzzy"
    t.boolean "deleted", default: false, null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "parent_medication_id"
    t.index ["deleted"], name: "index_medications_on_deleted"
    t.index ["parent_medication_id"], name: "index_medications_on_parent_medication_id"
    t.index ["position"], name: "index_medications_on_position"
    t.index ["project_id"], name: "index_medications_on_project_id"
    t.index ["start_date_fuzzy"], name: "index_medications_on_start_date_fuzzy"
    t.index ["stop_date_fuzzy"], name: "index_medications_on_stop_date_fuzzy"
    t.index ["subject_id"], name: "index_medications_on_subject_id"
  end

  create_table "notifications", force: :cascade do |t|
    t.bigint "user_id"
    t.boolean "read", default: false, null: false
    t.bigint "project_id"
    t.bigint "adverse_event_id"
    t.bigint "comment_id"
    t.bigint "handoff_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "sheet_unlock_request_id"
    t.bigint "export_id"
    t.bigint "sheet_id"
    t.index ["adverse_event_id"], name: "index_notifications_on_adverse_event_id"
    t.index ["comment_id"], name: "index_notifications_on_comment_id"
    t.index ["export_id"], name: "index_notifications_on_export_id"
    t.index ["handoff_id"], name: "index_notifications_on_handoff_id"
    t.index ["project_id"], name: "index_notifications_on_project_id"
    t.index ["read"], name: "index_notifications_on_read"
    t.index ["sheet_id"], name: "index_notifications_on_sheet_id"
    t.index ["sheet_unlock_request_id"], name: "index_notifications_on_sheet_unlock_request_id"
    t.index ["user_id"], name: "index_notifications_on_user_id"
  end

  create_table "old_passwords", force: :cascade do |t|
    t.bigint "user_id"
    t.string "encrypted_password"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_old_passwords_on_user_id"
  end

  create_table "organization_users", force: :cascade do |t|
    t.bigint "organization_id"
    t.bigint "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["organization_id", "user_id"], name: "index_organization_users_on_organization_id_and_user_id", unique: true
  end

  create_table "organizations", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "profile_picture"
  end

  create_table "profiles", force: :cascade do |t|
    t.string "username"
    t.string "description"
    t.bigint "user_id"
    t.bigint "organization_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["organization_id"], name: "index_profiles_on_organization_id", unique: true
    t.index ["user_id"], name: "index_profiles_on_user_id", unique: true
    t.index ["username"], name: "index_profiles_on_username", unique: true
  end

  create_table "project_languages", force: :cascade do |t|
    t.bigint "project_id"
    t.string "language_code"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["project_id", "language_code"], name: "index_project_languages_on_project_id_and_language_code", unique: true
  end

  create_table "project_preferences", force: :cascade do |t|
    t.bigint "project_id"
    t.bigint "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "position", default: 0, null: false
    t.boolean "archived", default: false, null: false
    t.boolean "emails_enabled", default: true, null: false
    t.index ["emails_enabled"], name: "index_project_preferences_on_emails_enabled"
    t.index ["user_id", "project_id"], name: "index_project_preferences_on_user_id_and_project_id", unique: true
  end

  create_table "project_users", force: :cascade do |t|
    t.bigint "project_id"
    t.bigint "user_id"
    t.boolean "editor", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "unblinded", default: true, null: false
    t.index ["project_id"], name: "index_project_users_on_project_id"
    t.index ["user_id"], name: "index_project_users_on_user_id"
  end

  create_table "projects", force: :cascade do |t|
    t.string "name", limit: 255
    t.text "description"
    t.bigint "user_id"
    t.boolean "deleted", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "logo", limit: 255
    t.datetime "logo_uploaded_at"
    t.boolean "disable_all_emails", default: false
    t.boolean "hide_values_on_pdfs", default: false, null: false
    t.string "slug"
    t.boolean "randomizations_enabled", default: false, null: false
    t.boolean "adverse_events_enabled", default: false, null: false
    t.boolean "blinding_enabled", default: false, null: false
    t.boolean "handoffs_enabled", default: false, null: false
    t.string "auto_lock_sheets", default: "never", null: false
    t.string "authentication_token"
    t.boolean "translations_enabled", default: false, null: false
    t.boolean "adverse_event_reviews_enabled", default: false, null: false
    t.boolean "medications_enabled", default: false, null: false
    t.index ["authentication_token"], name: "index_projects_on_authentication_token", unique: true
    t.index ["deleted"], name: "index_projects_on_deleted"
    t.index ["medications_enabled"], name: "index_projects_on_medications_enabled"
    t.index ["user_id"], name: "index_projects_on_user_id"
  end

  create_table "randomization_characteristics", force: :cascade do |t|
    t.bigint "project_id"
    t.bigint "randomization_scheme_id"
    t.bigint "list_id"
    t.bigint "randomization_id"
    t.bigint "stratification_factor_id"
    t.bigint "stratification_factor_option_id"
    t.bigint "site_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["list_id"], name: "index_randomization_characteristics_on_list_id"
    t.index ["project_id"], name: "index_randomization_characteristics_on_project_id"
    t.index ["randomization_id"], name: "index_randomization_characteristics_on_randomization_id"
    t.index ["randomization_scheme_id"], name: "index_randomization_characteristics_on_randomization_scheme_id"
    t.index ["site_id"], name: "index_randomization_characteristics_on_site_id"
    t.index ["stratification_factor_id"], name: "index_randomization_characteristics_on_stratification_factor_id"
    t.index ["stratification_factor_option_id"], name: "index_rc_on_stratification_factor_id"
  end

  create_table "randomization_schedule_prints", force: :cascade do |t|
    t.bigint "randomization_id"
    t.string "language"
    t.boolean "outdated", default: true, null: false
    t.string "file"
    t.bigint "file_size", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["randomization_id", "language"], name: "idx_randomization_schedules_prints", unique: true
  end

  create_table "randomization_scheme_tasks", force: :cascade do |t|
    t.bigint "randomization_scheme_id"
    t.text "description"
    t.integer "offset", default: 0, null: false
    t.string "offset_units"
    t.integer "window", default: 0, null: false
    t.string "window_units"
    t.integer "position", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["position"], name: "index_randomization_scheme_tasks_on_position"
    t.index ["randomization_scheme_id"], name: "index_randomization_scheme_tasks_on_randomization_scheme_id"
  end

  create_table "randomization_schemes", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.bigint "project_id"
    t.bigint "user_id"
    t.boolean "published", default: false, null: false
    t.integer "randomization_goal", default: 0, null: false
    t.boolean "deleted", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "algorithm", default: "permuted-block", null: false
    t.integer "chance_of_random_treatment_arm_selection", default: 30, null: false
    t.bigint "variable_id"
    t.string "variable_value"
    t.index ["deleted"], name: "index_randomization_schemes_on_deleted"
    t.index ["project_id", "deleted"], name: "index_randomization_schemes_on_project_id_and_deleted"
    t.index ["project_id"], name: "index_randomization_schemes_on_project_id"
    t.index ["user_id"], name: "index_randomization_schemes_on_user_id"
  end

  create_table "randomization_tasks", force: :cascade do |t|
    t.bigint "randomization_id"
    t.bigint "task_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["randomization_id"], name: "index_randomization_tasks_on_randomization_id"
    t.index ["task_id"], name: "index_randomization_tasks_on_task_id"
  end

  create_table "randomizations", force: :cascade do |t|
    t.bigint "project_id"
    t.bigint "randomization_scheme_id"
    t.bigint "user_id"
    t.bigint "list_id"
    t.integer "block_group", default: 0, null: false
    t.integer "multiplier", default: 0, null: false
    t.integer "position", default: 0, null: false
    t.bigint "treatment_arm_id"
    t.bigint "subject_id"
    t.datetime "randomized_at"
    t.bigint "randomized_by_id"
    t.boolean "attested", default: false, null: false
    t.boolean "deleted", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "dice_roll"
    t.integer "dice_roll_cutoff"
    t.text "past_distributions"
    t.text "weighted_eligible_arms"
    t.string "name"
    t.string "custom_treatment_name"
    t.index ["block_group"], name: "index_randomizations_on_block_group"
    t.index ["deleted"], name: "index_randomizations_on_deleted"
    t.index ["list_id"], name: "index_randomizations_on_list_id"
    t.index ["position"], name: "index_randomizations_on_position"
    t.index ["project_id"], name: "index_randomizations_on_project_id"
    t.index ["randomization_scheme_id", "deleted"], name: "index_randomizations_on_randomization_scheme_id_and_deleted"
    t.index ["randomization_scheme_id"], name: "index_randomizations_on_randomization_scheme_id"
    t.index ["randomized_by_id"], name: "index_randomizations_on_randomized_by_id"
    t.index ["subject_id"], name: "index_randomizations_on_subject_id"
    t.index ["treatment_arm_id"], name: "index_randomizations_on_treatment_arm_id"
    t.index ["user_id"], name: "index_randomizations_on_user_id"
  end

  create_table "responses", force: :cascade do |t|
    t.bigint "variable_id"
    t.text "value"
    t.bigint "sheet_variable_id"
    t.bigint "grid_id"
    t.bigint "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "sheet_id"
    t.bigint "domain_option_id"
    t.index ["domain_option_id"], name: "index_responses_on_domain_option_id"
    t.index ["sheet_id"], name: "index_responses_on_sheet_id"
    t.index ["sheet_variable_id"], name: "index_responses_on_sheet_variable_id"
  end

  create_table "sections", force: :cascade do |t|
    t.string "name", limit: 255
    t.text "description"
    t.bigint "project_id"
    t.bigint "design_id"
    t.bigint "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "level", default: 0, null: false
  end

  create_table "sheet_errors", force: :cascade do |t|
    t.bigint "project_id"
    t.bigint "sheet_id"
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["project_id"], name: "index_sheet_errors_on_project_id"
    t.index ["sheet_id"], name: "index_sheet_errors_on_sheet_id"
  end

  create_table "sheet_prints", force: :cascade do |t|
    t.bigint "sheet_id"
    t.string "language"
    t.boolean "outdated", default: true, null: false
    t.string "file"
    t.bigint "file_size", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["sheet_id", "language"], name: "index_sheet_prints_on_sheet_id_and_language", unique: true
  end

  create_table "sheet_transaction_audits", force: :cascade do |t|
    t.bigint "sheet_transaction_id"
    t.bigint "user_id"
    t.bigint "sheet_id"
    t.bigint "sheet_variable_id"
    t.bigint "grid_id"
    t.string "sheet_attribute_name"
    t.text "value_before"
    t.text "label_before"
    t.text "value_after"
    t.text "label_after"
    t.boolean "value_for_file", default: false, null: false
    t.datetime "created_at", null: false
    t.bigint "project_id"
    t.index ["grid_id"], name: "index_sheet_transaction_audits_on_grid_id"
    t.index ["project_id"], name: "index_sheet_transaction_audits_on_project_id"
    t.index ["sheet_id"], name: "index_sheet_transaction_audits_on_sheet_id"
    t.index ["sheet_transaction_id"], name: "index_sheet_transaction_audits_on_sheet_transaction_id"
    t.index ["sheet_variable_id"], name: "index_sheet_transaction_audits_on_sheet_variable_id"
    t.index ["user_id"], name: "index_sheet_transaction_audits_on_user_id"
  end

  create_table "sheet_transactions", force: :cascade do |t|
    t.string "transaction_type"
    t.bigint "sheet_id"
    t.bigint "user_id"
    t.string "remote_ip"
    t.datetime "created_at", null: false
    t.bigint "project_id"
    t.string "language_code"
    t.index ["project_id"], name: "index_sheet_transactions_on_project_id"
    t.index ["sheet_id"], name: "index_sheet_transactions_on_sheet_id"
    t.index ["user_id"], name: "index_sheet_transactions_on_user_id"
  end

  create_table "sheet_unlock_requests", force: :cascade do |t|
    t.bigint "sheet_id"
    t.bigint "user_id"
    t.text "reason"
    t.boolean "deleted", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["deleted"], name: "index_sheet_unlock_requests_on_deleted"
    t.index ["sheet_id"], name: "index_sheet_unlock_requests_on_sheet_id"
    t.index ["user_id"], name: "index_sheet_unlock_requests_on_user_id"
  end

  create_table "sheet_variables", force: :cascade do |t|
    t.bigint "variable_id"
    t.bigint "sheet_id"
    t.text "value"
    t.bigint "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "response_file", limit: 255
    t.bigint "domain_option_id"
    t.index ["domain_option_id"], name: "index_sheet_variables_on_domain_option_id"
    t.index ["sheet_id", "variable_id"], name: "index_sheet_variables_on_sheet_id_and_variable_id", unique: true
    t.index ["user_id"], name: "index_sheet_variables_on_user_id"
  end

  create_table "sheets", force: :cascade do |t|
    t.bigint "design_id"
    t.bigint "project_id"
    t.bigint "subject_id"
    t.bigint "user_id"
    t.boolean "deleted", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "last_user_id"
    t.string "authentication_token", limit: 255
    t.datetime "last_edited_at"
    t.integer "response_count"
    t.integer "total_response_count"
    t.bigint "subject_event_id"
    t.boolean "successfully_validated"
    t.bigint "adverse_event_id"
    t.boolean "missing", default: false, null: false
    t.datetime "unlocked_at"
    t.integer "percent"
    t.integer "uploaded_files_count"
    t.integer "comments_count", default: 0, null: false
    t.integer "errors_count", default: 0, null: false
    t.string "initial_language_code"
    t.bigint "ae_adverse_event_id"
    t.index ["adverse_event_id"], name: "index_sheets_on_adverse_event_id"
    t.index ["ae_adverse_event_id"], name: "index_sheets_on_ae_adverse_event_id"
    t.index ["authentication_token"], name: "index_sheets_on_authentication_token", unique: true
    t.index ["comments_count"], name: "index_sheets_on_comments_count"
    t.index ["deleted"], name: "index_sheets_on_deleted"
    t.index ["design_id"], name: "index_sheets_on_design_id"
    t.index ["errors_count"], name: "index_sheets_on_errors_count"
    t.index ["last_user_id"], name: "index_sheets_on_last_user_id"
    t.index ["missing"], name: "index_sheets_on_missing"
    t.index ["percent"], name: "index_sheets_on_percent"
    t.index ["project_id"], name: "index_sheets_on_project_id"
    t.index ["subject_event_id"], name: "index_sheets_on_subject_event_id"
    t.index ["subject_id"], name: "index_sheets_on_subject_id"
    t.index ["uploaded_files_count"], name: "index_sheets_on_uploaded_files_count"
    t.index ["user_id"], name: "index_sheets_on_user_id"
  end

  create_table "site_users", force: :cascade do |t|
    t.bigint "project_id"
    t.bigint "site_id"
    t.bigint "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "editor", default: false, null: false
    t.boolean "unblinded", default: true, null: false
    t.index ["project_id"], name: "index_site_users_on_project_id"
    t.index ["site_id"], name: "index_site_users_on_site_id"
    t.index ["user_id"], name: "index_site_users_on_user_id"
  end

  create_table "sites", force: :cascade do |t|
    t.string "name", limit: 255
    t.text "description"
    t.bigint "project_id"
    t.bigint "user_id"
    t.boolean "deleted", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "subject_code_format"
    t.string "short_name"
    t.integer "number"
    t.index ["deleted"], name: "index_sites_on_deleted"
    t.index ["number", "project_id"], name: "index_sites_on_number_and_project_id", unique: true
    t.index ["project_id"], name: "index_sites_on_project_id"
    t.index ["user_id"], name: "index_sites_on_user_id"
  end

  create_table "status_checks", force: :cascade do |t|
    t.bigint "check_id"
    t.bigint "sheet_id"
    t.boolean "failed"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["check_id", "sheet_id"], name: "index_status_checks_on_check_id_and_sheet_id", unique: true
    t.index ["failed"], name: "index_status_checks_on_failed"
  end

  create_table "stratification_factor_options", force: :cascade do |t|
    t.bigint "project_id"
    t.bigint "randomization_scheme_id"
    t.bigint "stratification_factor_id"
    t.bigint "user_id"
    t.string "label"
    t.integer "value", default: 0, null: false
    t.boolean "deleted", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["deleted"], name: "index_stratification_factor_options_on_deleted"
    t.index ["project_id"], name: "index_stratification_factor_options_on_project_id"
    t.index ["randomization_scheme_id"], name: "index_stratification_factor_options_on_randomization_scheme_id"
    t.index ["stratification_factor_id", "deleted"], name: "index_sfo_on_stratification_factor_id_and_deleted"
    t.index ["stratification_factor_id"], name: "index_stratification_factor_options_on_stratification_factor_id"
    t.index ["user_id"], name: "index_stratification_factor_options_on_user_id"
  end

  create_table "stratification_factors", force: :cascade do |t|
    t.bigint "project_id"
    t.bigint "randomization_scheme_id"
    t.bigint "user_id"
    t.string "name"
    t.boolean "deleted", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "stratifies_by_site", default: false, null: false
    t.text "calculation"
    t.index ["deleted"], name: "index_stratification_factors_on_deleted"
    t.index ["project_id"], name: "index_stratification_factors_on_project_id"
    t.index ["randomization_scheme_id", "deleted"], name: "index_sf_on_randomization_scheme_id_and_deleted"
    t.index ["randomization_scheme_id"], name: "index_stratification_factors_on_randomization_scheme_id"
    t.index ["user_id"], name: "index_stratification_factors_on_user_id"
  end

  create_table "subject_events", force: :cascade do |t|
    t.bigint "subject_id"
    t.bigint "event_id"
    t.date "event_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id"
    t.integer "unblinded_responses_count"
    t.integer "unblinded_questions_count"
    t.integer "unblinded_percent"
    t.integer "blinded_responses_count"
    t.integer "blinded_questions_count"
    t.integer "blinded_percent"
    t.index ["blinded_percent"], name: "index_subject_events_on_blinded_percent"
    t.index ["event_id"], name: "index_subject_events_on_event_id"
    t.index ["subject_id"], name: "index_subject_events_on_subject_id"
    t.index ["unblinded_percent"], name: "index_subject_events_on_unblinded_percent"
    t.index ["user_id"], name: "index_subject_events_on_user_id"
  end

  create_table "subjects", force: :cascade do |t|
    t.bigint "project_id"
    t.string "subject_code", limit: 255
    t.bigint "user_id"
    t.boolean "deleted", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "site_id"
    t.boolean "validated", default: false, null: false
    t.integer "randomizations_count", default: 0, null: false
    t.integer "unblinded_uploaded_files_count"
    t.integer "blinded_uploaded_files_count"
    t.index ["blinded_uploaded_files_count"], name: "index_subjects_on_blinded_uploaded_files_count"
    t.index ["deleted"], name: "index_subjects_on_deleted"
    t.index ["project_id"], name: "index_subjects_on_project_id"
    t.index ["randomizations_count"], name: "index_subjects_on_randomizations_count"
    t.index ["site_id"], name: "index_subjects_on_site_id"
    t.index ["unblinded_uploaded_files_count"], name: "index_subjects_on_unblinded_uploaded_files_count"
    t.index ["user_id"], name: "index_subjects_on_user_id"
  end

  create_table "tasks", force: :cascade do |t|
    t.bigint "project_id"
    t.bigint "user_id"
    t.text "description"
    t.date "due_date"
    t.date "window_start_date"
    t.date "window_end_date"
    t.boolean "completed", default: false, null: false
    t.boolean "only_unblinded", default: false, null: false
    t.boolean "deleted", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["completed"], name: "index_tasks_on_completed"
    t.index ["deleted"], name: "index_tasks_on_deleted"
    t.index ["due_date"], name: "index_tasks_on_due_date"
    t.index ["only_unblinded"], name: "index_tasks_on_only_unblinded"
    t.index ["project_id"], name: "index_tasks_on_project_id"
    t.index ["user_id"], name: "index_tasks_on_user_id"
    t.index ["window_end_date"], name: "index_tasks_on_window_end_date"
    t.index ["window_start_date"], name: "index_tasks_on_window_start_date"
  end

  create_table "translations", force: :cascade do |t|
    t.bigint "translatable_id"
    t.string "translatable_type"
    t.string "translatable_attribute"
    t.string "language_code"
    t.text "translation"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["translatable_id", "translatable_type", "translatable_attribute", "language_code"], name: "index_translation", unique: true
  end

  create_table "tray_prints", force: :cascade do |t|
    t.bigint "tray_id"
    t.string "language"
    t.boolean "outdated", default: true, null: false
    t.string "file"
    t.bigint "file_size", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["tray_id", "language"], name: "index_tray_prints_on_tray_id_and_language", unique: true
  end

  create_table "trays", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.string "slug"
    t.bigint "profile_id"
    t.integer "time_in_seconds", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "keywords"
    t.index ["slug", "profile_id"], name: "index_trays_on_slug_and_profile_id", unique: true
  end

  create_table "treatment_arms", force: :cascade do |t|
    t.string "name"
    t.bigint "project_id"
    t.bigint "randomization_scheme_id"
    t.integer "allocation", default: 0, null: false
    t.bigint "user_id"
    t.boolean "deleted", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "short_name"
    t.index ["deleted"], name: "index_treatment_arms_on_deleted"
    t.index ["project_id"], name: "index_treatment_arms_on_project_id"
    t.index ["randomization_scheme_id", "deleted"], name: "index_treatment_arms_on_randomization_scheme_id_and_deleted"
    t.index ["randomization_scheme_id"], name: "index_treatment_arms_on_randomization_scheme_id"
    t.index ["user_id"], name: "index_treatment_arms_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.boolean "deleted", default: false, null: false
    t.boolean "admin", default: false, null: false
    t.string "email", limit: 255, null: false
    t.string "encrypted_password", limit: 255, null: false
    t.string "reset_password_token", limit: 255
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip", limit: 255
    t.string "last_sign_in_ip", limit: 255
    t.string "confirmation_token", limit: 255
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string "unconfirmed_email", limit: 255
    t.integer "failed_attempts", default: 0
    t.string "unlock_token", limit: 255
    t.datetime "locked_at"
    t.string "authentication_token", limit: 255
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "theme"
    t.boolean "emails_enabled", default: false, null: false
    t.datetime "password_changed_at"
    t.boolean "sound_enabled", default: false, null: false
    t.string "full_name", default: "", null: false
    t.string "profile_picture"
    t.index ["authentication_token"], name: "index_users_on_authentication_token", unique: true
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["deleted"], name: "index_users_on_deleted"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["password_changed_at"], name: "index_users_on_password_changed_at"
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["unlock_token"], name: "index_users_on_unlock_token", unique: true
  end

  create_table "variables", force: :cascade do |t|
    t.text "display_name"
    t.text "description"
    t.string "header", limit: 255
    t.string "variable_type", limit: 255
    t.bigint "user_id"
    t.bigint "project_id"
    t.boolean "deleted", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "hard_minimum"
    t.integer "hard_maximum"
    t.string "name", limit: 32
    t.date "date_hard_maximum"
    t.date "date_hard_minimum"
    t.date "date_soft_maximum"
    t.date "date_soft_minimum"
    t.integer "soft_maximum"
    t.integer "soft_minimum"
    t.text "calculation"
    t.bigint "updater_id"
    t.string "calculated_format", limit: 255
    t.string "units", limit: 255
    t.boolean "multiple_rows", default: false, null: false
    t.text "autocomplete_values"
    t.string "prepend", limit: 255
    t.string "append", limit: 255
    t.boolean "show_current_button", default: false, null: false
    t.string "display_layout", default: "visible", null: false
    t.string "alignment", limit: 255, default: "vertical", null: false
    t.integer "default_row_number", default: 1, null: false
    t.string "scale_type", limit: 255, default: "radio", null: false
    t.bigint "domain_id"
    t.boolean "show_seconds", default: true, null: false
    t.string "time_duration_format", default: "hh:mm:ss", null: false
    t.boolean "hide_calculation", default: false, null: false
    t.string "field_note"
    t.string "time_of_day_format", default: "24hour", null: false
    t.string "date_format", default: "mm/dd/yyyy", null: false
    t.index ["deleted"], name: "index_variables_on_deleted"
    t.index ["domain_id"], name: "index_variables_on_domain_id"
    t.index ["project_id"], name: "index_variables_on_project_id"
    t.index ["user_id"], name: "index_variables_on_user_id"
    t.index ["variable_type"], name: "index_variables_on_variable_type"
  end

end

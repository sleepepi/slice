class AddCompletionCountsToSubjectEvents < ActiveRecord::Migration[5.0]
  def change
    add_column :subject_events, :unblinded_responses_count, :integer
    add_column :subject_events, :unblinded_questions_count, :integer
    add_column :subject_events, :unblinded_percent, :integer
    add_index :subject_events, :unblinded_percent
    add_column :subject_events, :blinded_responses_count, :integer
    add_column :subject_events, :blinded_questions_count, :integer
    add_column :subject_events, :blinded_percent, :integer
    add_index :subject_events, :blinded_percent
  end
end

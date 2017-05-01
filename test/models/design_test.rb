# frozen_string_literal: true

require 'test_helper'

# Test to assure that design imports work as intended.
class DesignTest < ActiveSupport::TestCase
  test 'sheet creation from import' do
    valid = User.find_by(email: 'valid@example.com')
    design = Design.create(
      name: 'Design Import from File',
      project_id: projects(:one).id,
      user_id: users(:valid).id,
      csv_file: File.open('test/support/design_import.csv')
    )
    design.create_variables!(
      'store_id' => { display_name: 'Store', variable_type: 'integer' },
      'gpa' => { display_name: 'Gpa', variable_type: 'numeric' },
      'buy_date' => { display_name: 'Buy date', variable_type: 'string' },
      'name' => { display_name: 'Name', variable_type: 'string' },
      'gender' => { display_name: 'Gender', variable_type: 'string' }
    )
    assert_equal 5, design.design_options.size
    assert_difference('Sheet.count', 20) do
      design.create_sheets!(projects(:one).sites.first, valid, '127.0.0.1')
    end
    assert_equal 20, design.sheets.count
    assert_equal 2, design.sheets.with_site(sites(:valid_range)).count
    assert_equal 18, design.sheets.with_site(sites(:one)).count
    assert_not_nil design.sheets.first.last_edited_at
  end
end

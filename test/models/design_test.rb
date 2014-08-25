require 'test_helper'

class DesignTest < ActiveSupport::TestCase

  test "sheet creation from import" do
    valid = User.find_by_email('valid@example.com')
    design = Design.create(
              name: 'Design Import from File',
              project_id: projects(:one).id,
              user_id: users(:valid).id,
              csv_file: File.open('test/support/design_import.csv')
            )
    design.create_variables!( {
                                "store_id" => { display_name: "Store", variable_type: "integer" },
                                "gpa" => { display_name: "Gpa", variable_type: "numeric" },
                                "buy_date" => { display_name: "Buy date", variable_type: "string"  },
                                "name" => { display_name: "Name", variable_type: "string" },
                                "gender" => { display_name: "Gender", variable_type: "string" }
                              } )
    assert_equal 5, design.options.size
    assert_difference('Sheet.count', 20) do
      design.create_sheets!(projects(:one).sites.first, 'pending', valid)
    end

    assert_equal 2, design.sheets.with_subject_status('valid').count
    assert_equal 18, design.sheets.with_subject_status('pending').count

    assert_equal 2, design.sheets.with_site(sites(:valid_range)).count
    assert_equal 18, design.sheets.with_site(projects(:one).sites.first).count
  end

end

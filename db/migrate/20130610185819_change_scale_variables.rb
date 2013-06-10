class ChangeScaleVariables < ActiveRecord::Migration
  def up
    Variable.where( variable_type: 'scale', scale_type: 'radio' ).update_all( variable_type: 'radio', alignment: 'scale' )
    Variable.where( variable_type: 'scale', scale_type: 'checkbox' ).update_all( variable_type: 'checkbox', alignment: 'scale' )
  end

  def down
    Variable.where( alignment: 'scale' ).update_all( variable_type: 'scale', alignment: 'vertical' )
  end
end

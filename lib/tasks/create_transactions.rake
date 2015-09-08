desc 'Reset transactions from original audits'
task :create_transactions => :environment do
  puts "Sheet Transactions: #{SheetTransaction.count}"
  puts "Sheet Transaction Audits: #{SheetTransactionAudit.count}"
  # ActiveRecord::Base.connection.execute("TRUNCATE sheet_transactions RESTART IDENTITY")
  # ActiveRecord::Base.connection.execute("TRUNCATE sheet_transaction_audits RESTART IDENTITY")
  # puts "Sheet Transactions: #{SheetTransaction.count}"
  # puts "Sheet Transaction Audits: #{SheetTransactionAudit.count}"

  Sheet.order(id: :desc).each do |sheet|
    if sheet.sheet_transactions.count > 0
      puts "Skipping #{sheet.project.name} projects/#{sheet.project.id}/sheets/#{sheet.id}"
      next
    end

    ActiveRecord::Base.transaction do
      current_time = nil
      transaction_type = 'sheet_create'
      sheet_transaction = SheetTransaction.create( transaction_type: transaction_type, project_id: sheet.project_id, sheet_id: sheet.id, user_id: sheet.user_id, remote_ip: (sheet.user ? sheet.user.current_sign_in_ip : nil) )

      ignored_attributes = %w(id created_at updated_at authentication_token deleted response_count total_response_count successfully_validated)

      sheet.attributes.reject{|k,v| ignored_attributes.include?(k.to_s)}.each do |k,v|
        value_before = nil
        value_after = nil
        if v.kind_of?(Array)
          value_before = v[0]
          value_after = v[1]
        else
          value_after = v
        end
        if k.to_s == 'locked'
          value_before = (value_before.to_s == '1' ? 'true' : 'false')
          value_after = (value_after.to_s == '1' ? 'true' : 'false')
        end
        if value_before != value_after
          sheet_transaction.sheet_transaction_audits.create( sheet_attribute_name: k.to_s, value_before: value_before, value_after: value_after, project_id: sheet_transaction.project_id, sheet_id: sheet_transaction.sheet_id, user_id: sheet_transaction.user_id )
        end
      end

      sheet.design.variables.each do |variable|
        sv = sheet.sheet_variables.find_by_variable_id(variable.id)
        if sv and sv.variable.variable_type == 'grid'
          sv.grids.each do |grid|
            value_before = (grid.variable.variable_type == 'checkbox' ? '[]' : nil)
            value_after = grid.get_response(:raw).to_s
            label_after = grid.get_response(:name).to_s
            value_for_file = (grid.variable.variable_type == 'file')
            if value_before != value_after
              sheet_transaction.sheet_transaction_audits.create( value_before: value_before, value_after: value_after, label_after: label_after, value_for_file: value_for_file, sheet_variable_id: sv.id, grid_id: grid.id, project_id: sheet_transaction.project_id, sheet_id: sheet_transaction.sheet_id, user_id: sheet_transaction.user_id )
            end
          end
        elsif sv and sv.variable.variable_type != 'grid'
          value_before = (sv.variable.variable_type == 'checkbox' ? '[]' : nil)
          value_after = sv.get_response(:raw).to_s
          label_after = sv.get_response(:name).to_s
          value_for_file = (sv.variable.variable_type == 'file')
          if value_before != value_after
            sheet_transaction.sheet_transaction_audits.create( value_before: value_before, value_after: value_after, label_after: label_after, value_for_file: value_for_file, sheet_variable_id: sv.id, project_id: sheet_transaction.project_id, sheet_id: sheet_transaction.sheet_id, user_id: sheet_transaction.user_id )
          end
        end
      end

      puts "Created Transactions for #{sheet.project.name} projects/#{sheet.project.id}/sheets/#{sheet.id}"
    end
  end

end

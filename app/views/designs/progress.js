$("#progress").html("<%= escape_javascript(render("designs/progress")) %>");

<% if @design.total_rows > 0 and @design.total_rows == @design.rows_imported %>
clearInterval(<%= params[:interval] %>);
flashMessage("Design import completed successfully.");
<% end %>

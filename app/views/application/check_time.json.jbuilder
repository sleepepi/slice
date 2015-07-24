json.message @message
json.status @status
if @time.class == Time
  json.time_string @time.strftime("%-l:%M:%S %P")
else
  json.time_string "Invalid Time"
end

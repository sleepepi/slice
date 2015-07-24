json.message @message
json.date @date
json.status @status
if @date.class == Date
  json.date_string @date.strftime("%B %d, %Y")
  json.year @date.year
  json.month @date.month
  json.day @date.day
else
  json.date_string "Invalid Date"
end

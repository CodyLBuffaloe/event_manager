#loads Ruby's CSV parser library
require "csv"
require "sunlight/congress"
require "erb"

Sunlight::Congress.api_key = "e179a6973728c4dd3fb1204283aaccb5"

#cleans up non-standard zipcodes
def clean_zipcode(zipcode)
  zipcode.to_s.rjust(5, "0")[0..4]
end

def legislators_by_zipcode(zipcode)
  legislators = Sunlight::Congress::Legislator.by_zipcode(zipcode)
end

def save_thank_you_letters(id, form_letter)
   Dir.mkdir("output") unless Dir.exists? "output"
   filename = "output/thanks_#{id}.html"

   File.open(filename, "w") do |file|
     file.puts form_letter
   end
end
# removes all non-Digits from number, cuts the leading 1, and breaks up digits
# into 3, 3, and 4 groups joining them eventually with a -
def sanitize_phone_number(phone_number)
  if phone_number.gsub(/\D/, "").match(/^1?(\d{3})(\d{3})(\d{4})/)
    phone_number = [$1, $2, $3].join("-")
  end
end

def popular_signup_hours(signup_time)
  signup_time.strptime
end
#testing our application is working
puts "EventManager Initialized!"

#block reads each line in our CSV and displays the first names and zipcodes in a column
contents = CSV.open "event_attendees.csv", headers: true, header_converters: :symbol

template_letter = File.read "form_letter.erb"
erb_template = ERB.new template_letter

contents.each do |row|
  id = row[0]
  name = row[:first_name]
  phone_number = sanitize_phone_number(row[:homephone])
  signup_time = row[:regdate]
  zipcode = clean_zipcode(row[:zipcode])
  legislators = legislators_by_zipcode(zipcode)
  form_letter = erb_template.result(binding)
  save_thank_you_letters(id, form_letter)
  puts signup_time
end
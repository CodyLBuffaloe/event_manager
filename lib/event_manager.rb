#loads Ruby's CSV parser library
require "csv"
#cleans up non-standard zipcodes
def clean_zipcode(zipcode)
  zipcode.to_s.rjust(5, "0")[0..4]
end
#testing our application is working
puts "EventManager Initialized!"
#block reads each line in our CSV and displays the first names and zipcodes in a column
contents = CSV.open "event_attendees.csv", headers: true, header_converters: :symbol
contents.each do |row|
  name = row[:first_name]
  zipcode = clean_zipcode(row[:zipcode])
  puts "#{name} #{zipcode}"
end
#loads Ruby's CSV parser library
require "csv"
require "sunlight/congress"

Sunlight::Congress.api_key = "e179a6973728c4dd3fb1204283aaccb5"

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
  legislators = Sunlight::Congress::Legislator.by_zipcode(zipcode)
  legislator_names = legislators.collect do |legislator|
    "#{legislator.first_name} #{legislator.last_name}"
  end
  legislator_string = legislator_names.join(", ")
  puts "#{name} #{zipcode} #{legislator_string}"
end
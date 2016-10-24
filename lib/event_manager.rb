class EventManager
#loads Ruby's CSV parser library
require "csv"
require "sunlight/congress"
require "erb"
require "date"

def initialize
  @hours = Hash.new
  @days = Hash.new
end

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



def time_scraper(signup_time)
  date = DateTime.strptime(signup_time, '%m/%d/%y %k:%M')
  hour = date.hour
  weekday = date.wday
  if(@hours[hour].nil?)
    @hours[hour] = 1
  else
    @hours[hour] += 1
  end

  if(@days[weekday].nil?)
    @days[weekday] = 1
  else
    @days[weekday] += 1
  end
end

def date_string(num)
  case (num.to_s)
    when "0"
      return "Sunday"
    when "1"
      return "Monday"
    when "2"
      return "Tuesday"
    when "3"
      return "Wednesday"
    when "4"
      return "Thursday"
    when "5"
      return "Friday"
    when "6"
      return "Saturday"
  end
end

def most_registrations_wday(signup_day)
  time_scraper(signup_day)
  highest_registrations_day = 0
  most_valuable_day = 0
  ad_days = []
  @days.each do|key, value|
    if(@days[key] > highest_registrations_day)
      highest_registrations_day = value
      most_valuable_day = key
      ad_days = []
      ad_days << most_valuable_day
    elsif(@days[key] == highest_registrations_day)
      ad_days << key
    end
  end
  day_string = ""
  day_string = date_string(ad_days[0])
  return "The most people signed up on #{day_string}."
end

def most_registered_hour(signup_time)
  time_scraper(signup_time)
  highest_registered_hour = 0
  valuable_hour = 0
  ad_times = []
  @hours.each do |key, value|
    if(@hours[key] > highest_registered_hour)
      highest_registered_hour = value
      valuable_hour = key
      ad_times = []
      ad_times << valuable_hour
    elsif(@hours[key] == highest_registered_hour)
      ad_times << key
    end

  end
  return "The most people signed up at #{ad_times[0]} hours and #{ad_times[1]} hours."
end

def run
#testing our application is working
puts "EventManager Initialized!"

#reads each line in our CSV and displays the first names and zipcodes in a column
contents = CSV.open "event_attendees.csv", headers: true, header_converters: :symbol

template_letter = File.read "form_letter.erb"
erb_template = ERB.new template_letter
signup_time = nil
signup_day = nil
contents.each do |row|
  id = row[0]
  name = row[:first_name]
  phone_number = sanitize_phone_number(row[:homephone])
  signup_time = most_registered_hour(row[:regdate])
  signup_day = most_registrations_wday(row[:regdate])
  zipcode = clean_zipcode(row[:zipcode])
  legislators = legislators_by_zipcode(zipcode)
  form_letter = erb_template.result(binding)
  save_thank_you_letters(id, form_letter)

end
  puts signup_time
  puts signup_day
end
end

c = EventManager.new
c.run
require 'csv'
require 'google/apis/civicinfo_v2'
require 'erb'
require 'time'

def clean_zipcode(zipcode)
  zipcode.to_s.rjust(5,"0")[0..4]
end

def legislators_by_zipcode(zip)
  civic_info = Google::Apis::CivicinfoV2::CivicInfoService.new
  civic_info.key = 'AIzaSyClRzDqDh5MsXwnCWi0kOiiBivP6JsSyBw'

  begin
    civic_info.representative_info_by_address(
      address: zip,
      levels: 'country',
      roles: ['legislatorUpperBody', 'legislatorLowerBody']
    ).officials
  rescue
    'You can find your representatives by visiting www.commoncause.org/take-action/find-elected-officials'
  end
end

def save_thank_you_letter(id,form_letter)
  Dir.mkdir('output') unless Dir.exist?('output')

  filename = "output/thanks_#{id}.html"

  File.open(filename, 'w') do |file|
    file.puts form_letter
  end
end

def clean_phone_numbers(phone)
  new_phone = phone.scan(/\d/).join('')
  len = new_phone.length

  if len < 10 || len > 11
    new_phone = 'bad'
  elsif len == 11 && new_phone[0].to_i != 1
    new_phone = 'bad'
  else
    if len == 11 && new_phone[0].to_i == 1
      new_phone = new_phone[1..10]
    end
  end

  return new_phone
end

def time_converting(record)
  time = Time.strptime(record, "%m/%d/%Y %k:%M")
  time
end

def time_targeting(records)
  counts = Hash.new(0)

  records.each do |num|
    counts[num] += 1
  end

  max_count = counts.values.max
  most_common_elements = counts.select { |key, value| value == max_count }.keys
  
  most_common_elements

end

puts 'EventManager initialized.'

contents = CSV.open(
  'event_attendees.csv',
  headers: true,
  header_converters: :symbol
)

=begin

template_letter = File.read('form_letter.erb')
erb_template = ERB.new template_letter

contents.each do |row|
  id = row[0]
  name = row[:first_name]
  zipcode = clean_zipcode(row[:zipcode])
  legislators = legislators_by_zipcode(zipcode)

  form_letter = erb_template.result(binding)

  save_thank_you_letter(id,form_letter)
end

contents.each do |row|
  phone = clean_phone_numbers(row[:homephone])
  puts phone
end

=end

time_records = Array.new

contents.each do |row|
  time = time_converting(row[:regdate])
  time_records << time.hour
end

puts time_targeting(time_records)


require "yomu"
require "json"
require "neatjson"

PAGE_HEADER_REGEX = /NUMBER PARTICIPANT ACCOUNT NAME/i
PAGE_SUBHEADER_REGEX = /DTC Participant Report.*?Month Ending.*?\n/mi
SERIES_HEADER_REGEX = /[0-9]+ SERIES/i
SHEET_REGEX = /Sheet[0-9]+\n/i
EMPTY_LINE_REGEX = /^\s*?$\n/
PARTICIPANT_LINE_REGEX = /(?<number>[0-9]+)\s+(?<account_name>[^\n]+)/

puts "Extracting text"
text = Yomu.new("./vendor/dtc_numerical_list.pdf").text

puts "Parsing text"
text.gsub!(PAGE_HEADER_REGEX, "")
text.gsub!(PAGE_SUBHEADER_REGEX, "")
text.gsub!(SERIES_HEADER_REGEX, "")
text.gsub!(SHEET_REGEX, "")
text.gsub!(EMPTY_LINE_REGEX, "")

participants = []
text.each_line do |participant_line|
  match = PARTICIPANT_LINE_REGEX.match(participant_line)
  participants << {
    number: match[:number],
    account_name: match[:account_name].strip,
  }
end

puts "Writing raw DTC data file"
File.write('./vendor/dtc-raw.json', JSON.neat_generate(participants, wrap: 200, after_comma: 1))

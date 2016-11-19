require "yomu"

PAGE_HEADER_REGEX = /NUMBER PARTICIPANT ACCOUNT NAME/i
PAGE_SUBHEADER_REGEX = /DTC Participant Report.*?Month Ending.*?\n/mi
SERIES_HEADER_REGEX = /[0-9]+ SERIES/i
SHEET_REGEX = /Sheet[0-9]+\n/i
EMPTY_LINE_REGEX = /^\s*?$\n/

text = Yomu.new("./dtc_numerical_list.pdf").text

text.gsub!(PAGE_HEADER_REGEX, "")
text.gsub!(PAGE_SUBHEADER_REGEX, "")
text.gsub!(SERIES_HEADER_REGEX, "")
text.gsub!(SHEET_REGEX, "")
text.gsub!(EMPTY_LINE_REGEX, "")

puts text

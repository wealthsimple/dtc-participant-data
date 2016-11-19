require "active_support/all"
require "pp"
require "json"
require "rest-client"
require "levenshtein"
require "neatjson"

BLOOMBERG_COMPANY_INFO_SUFFIX = /\: Private Company Information.*/

def search(account_name)
  params = {
    # key from google's demo page: https://enterprise.google.com/search/products/gss.html
    key: "AIzaSyBQj-LqUlRQeVVEW_zMsn7hzztuZH7teoI",
    cx: "001553978108429406595:qoop693jiyi",
    q: "site:bloomberg.com/research #{account_name}",
    num: 1,
  }
  response = RestClient::Request.execute({
    method: :get,
    url: "https://www.googleapis.com/customsearch/v1?#{params.to_param}",
    headers: {
      'Origin' => 'https://enterprise.google.com',
      'Referer' => 'https://enterprise.google.com/search/products/gss.html',
      'User-Agent' => 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_11_2) AppleWebKit/601.3.9 (KHTML, like Gecko) Version/9.0.2 Safari/601.3.9',
    },
  })
  JSON.parse(response)["items"]
rescue RestClient::Exception => e
  puts e
  puts e.response&.body
end

def normalize_account_name(account_name)
  puts account_name
  items = search(account_name)
  return unless items && items.size > 0
  title = items.first["title"]
  if title.match(BLOOMBERG_COMPANY_INFO_SUFFIX)
    normalized = title.sub(BLOOMBERG_COMPANY_INFO_SUFFIX, "")
    return if Levenshtein.distance(normalized.upcase, account_name) > 2
    puts normalized
    normalized
  end
end

raw_participants = JSON.parse(File.read("./vendor/dtc-raw.json"))
participants = []
raw_participants.each do |participant|
  account_name = normalize_account_name(participant["account_name"])
  account_name ||= participant["account_name"]
  participants << {
    number: participant["number"],
    account_name: account_name,
  }
end

File.write('./dtc-participant-data.json', JSON.neat_generate(participants, wrap: 200, after_comma: 1))

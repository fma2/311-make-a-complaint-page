require 'json'
require 'open-uri'
require 'net/http'
require 'jsonpretty'


def fetch(url)
	resp = Net::HTTP.get_response(URI.parse(url))
	data = resp.body
	JSON.parse(data)
end

def write_to_json_file(json, file)
	File.open(file,"w") do |f|
		f.write(json.to_json)
	end
end

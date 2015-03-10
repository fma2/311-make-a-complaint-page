require 'json'
require 'open-uri'
require 'net/http'
require 'jsonpretty'

def fetch(url)
	resp = Net::HTTP.get_response(URI.parse(url))
	data = resp.body
	JSON.parse(data)
end

def get_complaint_types(category)
	cat_temp = category.split(" ")
	cat_temp.each_with_index do |x, i|
		if x == "&"
			cat_temp[i] = '%26amp%3B'
		end
	end
	cat_temp = cat_temp.join("%20")
	fetch('http://www1.nyc.gov/apps/311srmap/lov.htm?category=' + cat_temp)
end

def extract_categories(url)
	page_json = fetch('http://www1.nyc.gov/apps/311srmap/lov.htm')["items"]
	categories_json = {}
	page_json.each do |cat|
		cat["name"].gsub!('&amp;','&')
		categories_json[cat["name"]] = []
	end
	categories_json
end

def build_category_complaint_types_json(url)
	categories = extract_categories(url)
	categories.each_pair do |k,v|
		json = get_complaint_types(k)
		complaints_for_category = json["items"].map do |complaint|
			if complaint["name"] != "All"
				v << complaint["name"]
			end
		end
	end
end

def write_to_json_file(json, file)
	File.open(file,"w") do |f|
		f.write(json.to_json)
	end
end

scraped_data = build_category_complaint_types_json('http://www1.nyc.gov/apps/311srmap/lov.htm')
write_to_json_file(scraped_data, 'public/scraped_data.json')

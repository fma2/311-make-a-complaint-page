require 'json'
require 'open-uri'
require 'net/http'
require 'jsonpretty'


## create json with topics linked to services/labels with info on categories, service_name, complaint_type, etc

def fetch(url)
	resp = Net::HTTP.get_response(URI.parse(url))
	data = resp.body
	JSON.parse(data)
end

def extract_topics_json(url)
	topics_json = Array.new
	topics_311 = fetch(url)[0]["topics"]
	topics_311.each do |topic|
		topics_json << topic
	end
	topics_json
end

def add_services_url_to_topics_json(url)
	topics_json = extract_topics_json(url)
	
	topics_json.each do |topic|
		topic["topics"].each do |subtopic|
			subtopic[:services_url] = "http://www1.nyc.gov/311_contentapi/services/#{subtopic['services'][0]["service_id"]}.json"
		end
	end
	topics_json
end

def find_category_names(url)
	page_json = fetch(url)
	# puts JSON.pretty_generate(page_json)
	page_json[0]["categories"]
end

def find_subtypes(url, subtype)
	page_json = fetch(url)
	list = Array.new
	page_json[0]["web_actions"].each do |action|
		if includes_item?(action["url"], subtype)
			action["url"].split(/[?,&]/).each do |substr|
				if includes_item?(substr, subtype)
					list << substr.split("=")[1]
				end
			end
		end
	end
	list
end

def includes_item?(str, item)
	if str.include?(item)
		return true
	end
end

services_list = create_topics_and_services_json('http://www1.nyc.gov/311_contentapi/booker.json')

# def add_category_name_and_complaint_type_per_service(url)
# 	services_list = create_services_urls_json(url).values

# 	services_list.each do |service|
# 		service.each do |s|
# 			service_url = s["services"][:services_url]
# 			categories = find_category_names(service_url)
# 			s[:categories] = categories

# 			complaint_types = find_subtypes(service_url, "complaintType").uniq		
# 			s[:complaint_types] = complaint_types

# 			service_names = find_subtypes(service_url, "serviceName").uniq
# 			s[:service_names] = service_names

# 			topic_names = find_subtypes(service_url, "topic").uniq
# 			s[:topic_names] = topic_names
# 		end
# 	end
# 	puts services_list
# 	create_json_file('services-list.json',services_list)
# end

# def parse_categories_with_related_info(url)
# 	list = add_category_name_and_complaint_type_per_service(url)
# 	categories_json = Hash.new
# 	list.each do |service|
# 		service.each do |x|			
# 			x.each do |y|
# 				# puts y["categories"]
# 				# categories_json[y[:categories]] = {} #do |y|
# 			end
# 				# categories_json[y] = {}
# 			# end
# 		end
# 	end
# 	# puts list[0][0]
# 	# puts "#" * 100
# 	# puts list[1]

# 	p categories_json
# end

# def create_json_file(filename, json)
# 	fJson = File.open(filename,"w")
# 	fJson.write(json)
# 	fJson.close
# end

# combine_page_json('http://www1.nyc.gov/311_contentapi/booker.json')
# file = File.read('all-services-data.json')
# data_hash = JSON.parse(file)

# File.open("../public/nys-senate-members-2015.json","w") do |f|
#   f.write(sm_json.to_json)
# end

# add_category_name_and_complaint_type_per_service('http://www1.nyc.gov/311_contentapi/booker.json')


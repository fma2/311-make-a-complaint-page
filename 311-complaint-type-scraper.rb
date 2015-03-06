require 'json'
require 'open-uri'
require 'net/http'
require 'jsonpretty'

def fetch(url)
	resp = Net::HTTP.get_response(URI.parse(url))
	data = resp.body
	JSON.parse(data)
end

def extract_topics_json(url)
	json = Array.new
	topics_311 = fetch(url)[0]["topics"]
	topics_311.each do |topic|
		json << topic
	end
	json
end

def add_services_url_to_topics_json(json)	
	json.each do |topic|
		topic["topics"].each do |subtopic|
			subtopic[:services_url] = "http://www1.nyc.gov/311_contentapi/services/#{subtopic['services'][0]["service_id"]}.json"
		end
	end
	json
end

def find_category_names(url)
	page_json = fetch(url)
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


def add_scraped_types_to_subtopic(url)
	topics_json = extract_topics_json(url)
	json = add_services_url_to_topics_json(topics_json)
	json.each do |topic|
		topic["topics"].each do |subtopic|
			services_url = subtopic[:services_url]

			subtopic[:categories] = find_category_names(services_url)

			complaint_types = find_subtypes(services_url, "complaintType").uniq
			subtopic[:complaint_types] = complaint_types.map { |x| x.split("%20").join(" ") }

			topic_names = find_subtypes(services_url, "topic").uniq
			p subtopic[:topic_types] = topic_names.map { |x| x.split("%20").join(" ") }
		end
	end
end

def create_topics_subtopics_types_json(url)
	add_scraped_types_to_subtopic(url)
end

topics_subtopics_types_json = create_topics_subtopics_types_json('http://www1.nyc.gov/311_contentapi/booker.json')

File.open("public/topics-subtopics-selected-types.json","w") do |f|
  f.write(topics_subtopics_types_json.to_json)
end

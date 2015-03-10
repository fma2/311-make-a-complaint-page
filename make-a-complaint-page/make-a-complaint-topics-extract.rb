load '../json-helper.rb'

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

def extract_category_names(url)
	page_json = fetch(url)
	page_json[0]["categories"]
end

def extract_specific_types(url,type)
	types = find_subtypes(url, type).uniq
	types.map {|x| x.split("%20").join(" ")}
end

def add_scraped_types_to_subtopic(url)
	topics_json = extract_topics_json(url)
	json = add_services_url_to_topics_json(topics_json)
	json.each do |topic|
		topic["topics"].each do |subtopic|
			services_url = subtopic[:services_url]

			subtopic[:categories] = extract_category_names(services_url)

			subtopic[:complaint_types] = extract_specific_types(services_url, "complaintType")

			subtopic[:topic_types] = extract_specific_types(services_url, "topic")
		end
	end
	json
end


def create_topics_subtopics_types_json(url)
	add_scraped_types_to_subtopic(url)
end

def create_empty_category_buckets(url)
	json = add_scraped_types_to_subtopic(url)
	category_buckets = Hash.new
	json.each do |topic|
		topic["topics"].each do |subtopic|
			subtopic[:categories].each do |info|
				category_buckets[info["category_name"]] = Array.new 
			end
		end
	end
	category_buckets
end

def create_category_buckets_json(url)
	category_buckets_json = create_empty_category_buckets(url)
	json = add_scraped_types_to_subtopic(url)
	json.each do |topic|
		topic["topics"].each do |subtopic|
			subtopic[:categories].each do |info|
				category_buckets_json[info["category_name"]] << {
					topic: topic["label"],
					subtopic: subtopic["label"],
					complaint_types: subtopic[:complaint_types]
				}
			end
		end
	end
	category_buckets_json
end


category_buckets_with_topics = create_category_buckets_json('http://www1.nyc.gov/311_contentapi/booker.json')
write_to_json_file(category_buckets_with_topics, 'public/category-buckets-with-topics.json')

topics_subtopics_types_json = create_topics_subtopics_types_json('http://www1.nyc.gov/311_contentapi/booker.json')
write_to_json_file(topics_subtopics_types_json, 'public/topics-subtopics-selected-types.json')
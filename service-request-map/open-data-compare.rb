load '../json-helper.rb'
load 'service-request-map-scraper.rb'

def open_data_complaint_types_list(url)
	data = fetch(url)
	complaint_types = Array.new
	data["data"].each do |x|
		complaint_types << x[8]
	end
	complaint_types.sort
end

def compare_sources(open_data, scraped_data)
	common_complaint_types = Hash.new
	scraped_data.each_pair do |k,v|
		common_complaint_types[k] = []
	end

	scraped_data.each_pair do |k,v|
		v.each do |complaint|
			if open_data.include?(complaint)
				common_complaint_types[k] << complaint
			end
		end
	end
	common_complaint_types
end

def find_missing_srmap_types(open_data, scraped_data)
	uncommon_complaint_types = Hash.new
	scraped_data.each_pair do |k,v|
		uncommon_complaint_types[k] = []
	end

	scraped_data.each_pair do |k,v|
		v.each do |complaint|
			if open_data.include?(complaint)
				next
			else
				uncommon_complaint_types[k] << complaint
			end
		end
	end
	uncommon_complaint_types
end

def find_missing_od_types(open_data, common_types_list)
	uncommon_complaint_types = Array.new
	open_data.each do |complaint|
		if common_types_list.include?(complaint)
			next
		else
			uncommon_complaint_types << complaint
		end
	end
	uncommon_complaint_types	
end

od_complaint_types = open_data_complaint_types_list('https://data.cityofnewyork.us/api/views/h4xh-jcuz/rows.json')

scraped_data_complaint_types = build_category_complaint_types_json('http://www1.nyc.gov/apps/311srmap/lov.htm')

# create common complaint types json file
common_complaint_types = compare_sources(od_complaint_types, scraped_data_complaint_types)
write_to_json_file(common_complaint_types, 'public/common-complaint-types.json')
puts "Number of common complaint types: "
puts common_complaint_types["All"].count #98

#create uncommon sr-map complaint types json file
sr_map_uncommon_complaint_types = find_missing_srmap_types(od_complaint_types,scraped_data_complaint_types)
write_to_json_file(sr_map_uncommon_complaint_types, 'public/sr_map_uncommon_complaint_types_list.json')
puts "Number of uncommon complaint types from service request map list: "
puts sr_map_uncommon_complaint_types["All"].count #46

# create uncommon open data complaint types json file
od_uncommon_complaint_types = find_missing_od_types(od_complaint_types, common_complaint_types["All"])
write_to_json_file(od_uncommon_complaint_types, 'public/od_uncommon_complaint_types_list.json')
puts "Number of uncommon complaint types from open data list: "
puts od_uncommon_complaint_types.count #147

# create open data complaint types list file
write_to_json_file(od_complaint_types, 'public/open_data_complaint_types_list.json')
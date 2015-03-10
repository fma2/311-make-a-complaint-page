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

od_complaint_types = open_data_complaint_types_list('https://data.cityofnewyork.us/api/views/h4xh-jcuz/rows.json')
scraped_data_complaint_types = build_category_complaint_types_json('http://www1.nyc.gov/apps/311srmap/lov.htm')

common_complaint_types = compare_sources(od_complaint_types, scraped_data_complaint_types)
write_to_json_file(common_complaint_types, 'public/common-complaint-types.json')

write_to_json_file(od_complaint_types, 'public/open_data_complaint_types_list.json')
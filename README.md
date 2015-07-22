# nyc-311-service-sites-scrape

This repository contains information pulled from the (1) [NYC 311 Make a Complaint web application](http://www1.nyc.gov/311/index.page) and (2) [NYC 311 Service Request Map](http://www1.nyc.gov/apps/311srmap/).  Read below to learn more about each site and about the information from each in this repository.

Results from scrape available as Google Doc [here](https://docs.google.com/document/d/1ON143VSMC9bDExlWFV7sG-Ly29949JAg5QPLkr2DGpk/edit).


##### NYC 311 Make a Complaint Application

From the NYC 311 Make a Complaint application,  topics (e.g. "Your Home") and subtopics (e.g. for "Your Home" -> "Heat or Hot Water") one can view via the drop-down menus on the application and can also find in [this json](http://www1.nyc.gov/311_contentapi/booker.json) were extracted and parsed.  

On the application, when a subtopic is selected, it loads information from a unique json.  For example, when "Heat or Hot Water" is selected, it loads [this json](http://www1.nyc.gov/311_contentapi/services/20090318-D7301A3A-13C9-11DE-B3B8-E2470D3B2251.json). 

In this repository, [make-a-complaint-page/public/topics-subtopics-selected-types.json](https://github.com/fma2/nyc-311-service-sites-scrape/blob/master/make-a-complaint-page/public/topics-subtopics-selected-types.json) contains topics, subtopics, subtopics' json links, and added details about each subtopic found in its unique json: categories, complaint types, and topic names.

[make-a-complaint-page/public/category-buckets-with-topics.json](https://github.com/fma2/nyc-311-service-sites-scrape/blob/master/make-a-complaint-page/public/category-buckets-with-topics.json) groups topics, subtopics, and complaint types (if any) by identified category.  Category assignments were found in each subtopic's unique json - e.g. ['Heat or Hot Water'](http://www1.nyc.gov/311_contentapi/services/20090318-D7301A3A-13C9-11DE-B3B8-E2470D3B2251.json).

##### NYC 311 Service Request Map

From the NYC 311 Service Request map, service request categories and their connected complaint types were extracted and parsed.

[service-request-map/public/scraped_data.json](https://github.com/fma2/nyc-311-service-sites-scrape/blob/master/service-request-map/public/scraped_data.json) contains a json with service request categories mapped with complaint types.
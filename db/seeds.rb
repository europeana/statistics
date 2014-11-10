userlist = [{"email"=> "al@pykih.com", "password" => "afzal199"},
            {"email"=> "mirko@jplusplus.org", "password" => "europeana*#"},
            {"email"=> "neil.bates@kb.nl", "password" => "europeana*#"},
          ]

User.delete_all            
userlist.each do |user|
  user_save = User.new(email: user["email"], password: user["password"])
  user_save.save!
end

Core::Oauth.delete_all
Core::Oauth.create(name: "Europeana", profile: "25899454", refresh_token: "1/2H6qnOsH0gcrJA_TQPJhffWmAkj-jCuu7uj3iwv0bUY")
Core::Oauth.create(name: "Europeana 1914-1918", profile: "43980802", refresh_token: "1/2H6qnOsH0gcrJA_TQPJhffWmAkj-jCuu7uj3iwv0bUY")

Setting.delete_all
json_data = {
  "collection_in_europeana_title"=>"Collection in Europeana", 
  "collection_in_europeana_description"=>"Digital objects in Europeana", 
  "media_types_title"=>"Media Types", 
  "media_types_description"=>"This chart displays a breakdown of the composition of the collection that has been made availible via Europeana.eu.",
  "reusable_title"=>"Reusable", 
  "reusable_description"=>"This chart displays what percentage of the collection is reusable based on the licenses that have been assigned to the digital objects in the collection.",
  "views_on_europeana_title"=>"Views on Europeana", 
  "views_on_europeana_description"=>"For the selected time period the data and charts in the category are based on the number of views of the Wellcome Library collection on Europeana.eu. The number of views for a collection are dependant on a number of factors such as the size of the collection, the quality of the meta-data that accompanies each digital object and the re-usability of the collection.", 
  "views_and_clickthroughs_title"=>"Views &amp; Click-Throughs", 
  "views_and_clickthroughs_description"=>"This charts displays the total views of the collection on Europeana.eu and the number of times a user clicked through to the providers website. Repeated views and click-throughs of the same digital objects are counted.", 
  "top_25_countries_title"=>"Top 25 Countries",
  "top_25_countries_description"=>"This chart displays the top 25 countries that generated the most views for this collection on Europeana.eu.", 
  "top_10_digital_objects_title"=>"Top 10 Digital Objects",
  "top_10_digital_objects_description"=>"This chart displays the top 10 digital objects from the collection that generated the most views on Europeana.eu."
}
setting = Setting.new(masonry: true,page_builder_config: json_data.to_json)
setting.save!
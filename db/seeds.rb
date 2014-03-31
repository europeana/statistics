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
setting = Setting.new(masonry: true)
setting.save!
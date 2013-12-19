userlist = [{"name"=>"afzal","email"=> "al@pykih.com", "password" => "afzal199"}]

userlist.each do |user|
  user_save = User.new(name: user["name"], email: user["email"], password: user["password"])
  user_save.save!
end
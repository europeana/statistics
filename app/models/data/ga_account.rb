class Data::GaAccount < ActiveRecord::Base
  
  #GEMS USED
  self.table_name = :data_ga_accounts
  
  #CONSTANTS
  GA_URL = "https://www.googleapis.com/analytics/v3/management/accounts"
  
  #ACCESSORS
  attr_accessible :core_oauth_id, :name, :profile_id, :user_id, :account_id
  
  #ASSOCIATIONS
  belongs_to :core_oauth, class_name: "Core::Oauth", foreign_key: "core_oauth_id"
  belongs_to :user
  
  #VALIDATIONS
  validates :name, presence: :true
  validates :core_oauth_id, presence: :true
  validates :profile_id, presence: :true
  validates :user_id, presence: :true
  validates :account_id, presence: :true
  validate  :check_uniqueness, on: :create
  
  #CALLBACKS
  #SCOPES
  #CUSTOM SCOPES
  #OTHER METHODS
  def self.get_accounts(oauth)
    begin
      oauth.reauthenticate?
      token = "access_token=#{oauth.token}"
      url = "#{GA_URL}?#{token}"
      a = GRuby::Util.get_json(Nestful.get(url))
      if a.present?
        if a["items"].first.present?
          a["items"].each do |account|
            if account["id"].present?
              url2 = "#{account["selfLink"]}/webproperties/UA-#{account["id"]}-1/profiles?#{token}"
              p = GRuby::Util.get_json(Nestful.get(url2))
              if p.present?
                if p["items"].first.present?
                  profile = p["items"].first
                  Data::GaAccount.create!(user_id: User.current.id, 
                                          core_oauth_id: oauth.id, 
                                          name: account["name"], 
                                          account_id: account["id"], 
                                          profile_id: profile["id"])
                end
              end
            end
          end
        end  
      end
      return nil
    rescue Exception => ex
      return ex.message.to_s
    end
  end
  
  #UPSERT
  #JOBS
  #PRIVATE
  private
  
  def check_uniqueness
    g = Data::GaAccount.where(user_id: self.user_id, core_oauth_id: self.core_oauth_id, name: self.name, profile_id: self.profile_id, account_id: self.account_id).first
    if g.present?
      errors.add(:name, "already exists.")
    end
  end
  
end

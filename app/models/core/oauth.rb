class Core::Oauth < ActiveRecord::Base
  
  #GEMS USED
  self.table_name = :core_oauths
  
  #CONSTANTS
  HEADER_ROW = "date,country,sourceMedium,keyword,deviceCategory,pagePath,LandingPagePath,visitors,newVisits,visits,bounces,avgTimeOnSite,pageviewsPerVisit,pageviews,avgTimeOnPage,exits,year,month,day,source,medium"
  
  #ACCESSORS
  attr_accessible :expires_at, :name, :profile, :refresh_token, :token
  
  #ASSOCIATIONS
  #VALIDATIONS
  validates :name, uniqueness: true
  
  #CALLBACKS
  after_create :after_create_set
  
  #SCOPES
  #CUSTOM SCOPES
  #OTHER METHODS  
  
  def data_filz
    Data::Filz.where(core_oauth_id: self.id).first
  end
  
  def reauthenticate?
    if (self.expires_at.present? and Time.now - self.expires_at > 0) or self.expires_at.blank?
      g = Nestful.post "https://accounts.google.com/o/oauth2/token?method=POST&grant_type=refresh_token&refresh_token=#{self.refresh_token}&client_id=#{GOOGLE_CLIENTID}&client_secret=#{GOOGLE_SECRET}"
      j = Core::Services.get_json(g)
      self.update_attributes(token: j["access_token"], expires_at: Time.now + j["expires_in"])
    end
    true
  end
  
  #developers.google.com/analytics/devguides/reporting/core/dimsmets
  def ga(qry, sd, ed)
    begin
      url = "https://www.googleapis.com/analytics/v3/data/ga?access_token=#{self.token}&start-date=#{sd}&end-date=#{ed}&ids=ga:#{self.profile}&max-results=10000#{qry}"
      a = Core::Services.get_json(Nestful.get(url))
      if a.present?
        if a["totalsForAllResults"].present?
          return a["rows"]
        end
      end
      return nil
    rescue => e
      return {status: "fail", message: e.inspect}
    end
  end
  
  #UPSERT
  #JOBS
  #PRIVATE
  private  
  
  def after_create_set
    Data::Filz.create!(genre: "API", file_file_name: "#{self.name}: Google Analytics Query 1", core_oauth_id: self.id)
    true
  end
  
  #Jobs::Ga.query(self.id, "first")
  
end
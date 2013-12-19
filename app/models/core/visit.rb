class Core::Visit < ActiveRecord::Base
  
  #GEMS USED
  self.table_name = :core_visits
  
  #ACCESSORS
  attr_accessible :account_id, :browser, :browser_version, :browser_genre, :caller_host, :created_at, :current_user_id, :device_brand, :device_genre, :device_model, :http_method, :ip, :is_bot, :lang, :os, :os_version, :path_from, :path_to, :raw_user_agent, :visitable_id, :visitable_type, :day_of_week, :day, :month, :year, :hour
  
  #ASSOCIATIONS
  belongs_to :user, :class_name => 'User', :foreign_key => "current_user_id"
  belongs_to :account
  belongs_to :visitable, :polymorphic => true
  
  #VALIDATIONS
  #CALLBACKS
  before_create :before_create_set
  
  #SCOPES
  scope :by_platform, select("distinct(device_genre) as dimension, count(*) as count").group(:device_genre)
  scope :by_device, select("distinct(device_brand) as dimension, count(*) as count").group(:device_brand)
  scope :by_os, select("distinct(os) as dimension, count(*) as count").group(:os)
  scope :by_browser, select("distinct(browser) as dimension, count(*) as count").group(:browser)
  scope :by_lang, select("distinct(lang) as dimension, count(*) as count").group(:lang)
  
  #CUSTOM SCOPES
  #OTHER METHODS
  def self.filter(uid, aid)
    if uid.present? and aid.present?
      Core::Visit.where(current_user_id: uid, account_id: aid)
    elsif uid.blank? and aid.present?
      Core::Visit.where(account_id: aid)
    elsif uid.present? and aid.blank?
      Core::Visit.where(current_user_id: uid)
    else
      Core::Visit
    end
  end
  
  def self.log(request, current_user, account_object)
    c = Core::Visit.new(path_to: request.env["REQUEST_PATH"], 
                        account_id: (account_object.blank? ? nil : account_object.id),
                        path_from: request.env["HTTP_REFERER"],
                        http_method: request.env["REQUEST_METHOD"],
                        ip: request.env["REMOTE_ADDR"],
                        caller_host: request.env["REMOTE_HOST"],
                        raw_user_agent: request.env["HTTP_USER_AGENT"],
                        lang: request.env["HTTP_ACCEPT_LANGUAGE"],
                        current_user_id: (current_user.blank? ? nil : current_user.id))
    u                 = AgentOrange::UserAgent.new(request.env["HTTP_USER_AGENT"])   
    c.browser         = u.device.engine.browser.to_s
    c.browser_genre   = u.device.engine.browser.name.to_s
    c.browser_version = u.device.engine.browser.version.to_s
    c.device_genre    = u.device.to_s
    c.device_brand    = u.device.platform.to_s
    c.device_model    = u.device.platform.version.to_s
    c.is_bot          = u.device.is_bot?
    c.os              = u.device.operating_system.to_s
    c.os_version      = u.device.operating_system.version.to_s
    c.save
  end
  
  #UPSERT
  def self.upsert #insert or update
  end
  #JOBS
  #PRIVATE
  private
  
  def before_create_set
    self.created_at  = Time.now
    self.day         = self.created_at.day
    self.month       = self.created_at.month
    self.year        = self.created_at.year
    self.hour        = self.created_at.hour
    self.day_of_week = self.created_at.strftime("%a")
    true
  end
  
end

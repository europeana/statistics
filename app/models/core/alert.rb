class Core::Alert < ActiveRecord::Base
  
  #GEMS USED
  self.table_name = :core_alerts
  
  #ACCESSORS
  attr_accessible :account_id, :action, :description, :updated_by, :alertable_type, :alertable_id
  
  #ASSOCIATIONS
  belongs_to :updator, :class_name => 'User', :foreign_key => "updated_by"
  belongs_to :account
  belongs_to :alertable, :polymorphic => true
  
  #VALIDATIONS
  #CALLBACKS
  before_create :before_create_set
  
  #SCOPES
  #CUSTOM SCOPES
  #OTHER METHODS  
  def self.log(a, b, c=nil, d=nil, e=nil)
    Core::Alert.create!(account_id: a, action: b, alertable_type: c, alertable_id: d, description: e)
    true
  end
  
  #UPSERT
  #JOBS
  #PRIVATE
  private
  
  def before_create_set
    self.updated_by = User.current.id
    true
  end
  
end

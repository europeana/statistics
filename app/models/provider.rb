require 'rake'
class Provider < ActiveRecord::Base
  attr_accessible :provider_type, :provider_id, :name, :requested_at, :request_end, :is_processed, :wiki_name,:text_at_top,:text_at_bottom,:error_message

  def generate_page(name,id,type)
    load File.join(Rails.root, 'lib', 'tasks', 'page_generator.rake')
    Rake::Task["page_generator:add_provider"].invoke(name,id,type)
  end

  def start_page_builder_process
    self.requested_at = Time.now
    self.is_processed = false
    self.request_end = nil
    self.save!      
    system "bundle exec rake 'page_generator:add_provider[#{self.name},#{self.provider_id},#{self.provider_type},#{self.wiki_name}]' &"
  end

end
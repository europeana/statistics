require 'rubygems'

# EVERY TEN MINUTES JOBS - SEQUENCED
task :every_10_mins => :environment do
  begin
  rescue Exception => e
    $stderr.puts "[JOB_ERROR] every_10_mins " + e.to_s
    #ExceptionNotifier::Notifier.background_exception_notification(e)
  end
end

# DAILY JOBS - SEQUENCED
task :every_day => :environment do
  begin
    puts "Analytics"
    Jobs::Ga.job
  rescue Exception => e
    $stderr.puts "[JOB_ERROR] every_day " + e.to_s
    #ExceptionNotifier::Notifier.background_exception_notification(e)
  end
end
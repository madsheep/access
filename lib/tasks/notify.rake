require_relative '../../app/models/slack_notification'
require_relative '../../config/preinitializer'

task :notify do
  notifier = SlackNotification.new(message: message)
  notifier.ping!
end

def message
  "Click here: #{ENV['REVIEW_PATH']} to review.\nClick here: #{ENV['APP_URL']} to apply."
end

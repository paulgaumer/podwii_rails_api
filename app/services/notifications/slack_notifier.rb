require "slack-notifier"

class Notifications::SlackNotifier
  def self.call(email, podcast)
    url = ENV["SLACK_WEBHOOK_URL"]
    notifier = Slack::Notifier.new(url)
    notifier.ping "🎉 New user: #{email}, Podcast: [#{podcast}] 🎉"
  end
end

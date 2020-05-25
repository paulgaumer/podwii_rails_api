require "slack-notifier"

class Notifications::SlackNotifier
  def self.call(email, podcast)
    url = "https://hooks.slack.com/services/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"
    notifier = Slack::Notifier.new(url)
    notifier.ping "🎉 New user: #{email}, Podcast: [#{podcast}] 🎉"
  end
end

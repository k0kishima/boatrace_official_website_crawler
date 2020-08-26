class Notification
  include ActiveModel::Model
  include ActiveModel::Attributes
  include ActiveModel::Validations

  attribute :type, :string

  def notify(message)
    chat_client.chat_postMessage(channel: channel, text: message)
  end

  private

    def chat_client
      @chat_client ||= Slack::Web::Client.new
    end

    def channel
      SlackChannel.new(information_type: type).name
    end
end
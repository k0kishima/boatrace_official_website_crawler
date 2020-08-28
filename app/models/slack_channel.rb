class SlackChannel
  include ActiveModel::Model
  include ActiveModel::Attributes
  include ActiveModel::Validations

  PREFIX = '001_crawler'

  attribute :information_type, :string
  validates :information_type, presence: true, inclusion: { in: %w(info) }

  def name
    validate!
    [PREFIX, Rails.env, information_type].join('_')
  end
end
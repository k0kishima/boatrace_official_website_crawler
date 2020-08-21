class EventHolding
  include ActiveModel::Model
  include ActiveModel::Attributes
  include ActiveModel::Validations

  attribute :date, :date
  attribute :day, :date

  validates :date, presence: true
  validates :day, presence: true
end
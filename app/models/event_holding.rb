class EventHolding
  include ActiveModel::Model
  include ActiveModel::Attributes
  include ActiveModel::Validations

  attribute :stadium_tel_code, :integer
  attribute :date, :date

  validates :stadium_tel_code, presence: true, inclusion: 1..24
  validates :date, presence: true
end
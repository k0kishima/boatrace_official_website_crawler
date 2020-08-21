class EventHoldingParserFactory
  def self.create(version)
    V1707::EventHoldingParser
  end
end
class EventParserFactory
  def self.create(version)
    V1707::EventParser
  end
end

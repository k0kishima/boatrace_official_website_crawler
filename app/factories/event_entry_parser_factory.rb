class EventEntryParserFactory
  def self.create(version)
    V1707::EventEntryParser
  end
end

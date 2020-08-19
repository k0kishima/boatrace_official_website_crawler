class RaceEntryParserFactory
  def self.create(version)
    V1707::RaceEntryParser
  end
end
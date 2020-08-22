class RaceRecordParserFactory
  def self.create(version)
    V1707::RaceRecordParser
  end
end

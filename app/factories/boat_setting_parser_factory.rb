class BoatSettingParserFactory
  def self.create(version)
    V1707::BoatSettingParser
  end
end

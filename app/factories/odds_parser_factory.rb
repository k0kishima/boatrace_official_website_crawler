class OddsParserFactory
  def self.create(version)
    V1707::OddsParser
  end
end

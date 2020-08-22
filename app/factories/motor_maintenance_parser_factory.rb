class MotorMaintenanceParserFactory
  def self.create(version)
    V1707::MotorMaintenanceParser
  end
end

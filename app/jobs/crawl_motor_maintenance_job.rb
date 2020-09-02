class CrawlMotorMaintenanceJob < ApplicationJob
  queue_as :high_priority

  # NOTE:
  # モーターの場合は中止レースパースしても例外あがってこないから例外のハンドリングは不要
  #  節単位での中止もしくは開催自体中止の場合 → 処理対象にならない
  #  当日中止が決まったレースの場合 → パースはされるがデータがないと単に何もしないだけ = エラーなどは起きない
  def perform(version:, stadium_tel_code:, date:, race_number:)
    no_cache = attempt_number > 1
    CrawlMotorMaintenanceService.call(version: version, stadium_tel_code: stadium_tel_code, date: date, race_number: race_number, no_cache: no_cache)
  end
end

namespace :crawl do
  def official_web_site_version
    (ENV['USE_VERSION'].presence || Rails.application.config.x.official_website_proxy.latest_official_website_version).to_i
  end

  desc 'Crawl event in specified year and month'
  task events: :environment do
    year = (ENV['YEAR'].presence || Time.zone.today.year).to_i
    month = (ENV['MONTH'].presence || Time.zone.today.month).to_i
    date = Date.new(year, month)
    # NOTE:
    # 公式サイトの仕様変更で何ヶ月先取れるかは変わるはず
    # リニューアルされた時点で要修正
    if 2.month.since.beginning_of_month.to_date <= date
      raise StandardError.new('Cannot fetch schedules in which 2 months ahead')
    end
    CrawlEventScheduleService.call(version: official_web_site_version, year: date.year, month: date.month)
  end
end
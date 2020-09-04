class CancelEventService
  include ServiceBase

  def call
    raise TooFastToCrawl.new if event_starts_on > Time.zone.today
    EventRepository.make_canceled(stadium_tel_code: stadium_tel_code, starts_on: event_starts_on)
  end

  private

    attr_accessor :stadium_tel_code, :event_starts_on

end

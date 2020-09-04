require 'open-uri'

module FileReloadable
  extend ActiveSupport::Concern
  included do
    retry_on OpenURI::HTTPError, wait: 1.minutes, attempts: 3
    retry_on Net::OpenTimeout, wait: 1.minutes, attempts: 3
    retry_on NoMethodError, wait: 1.minutes, attempts: 3

    def no_cache
      attempt_number > 1
    end
  end
end

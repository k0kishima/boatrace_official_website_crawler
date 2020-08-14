module HtmlParser
  extend ActiveSupport::Concern
  included do
    def initialize(string_or_io)
      @doc = Nokogiri::HTML.parse(string_or_io)
    end

    private

      attr_reader :doc
  end
end

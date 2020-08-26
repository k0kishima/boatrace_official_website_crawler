module HtmlParser
  extend ActiveSupport::Concern
  included do
    def initialize(file)
      @doc = Nokogiri::HTML.parse(file.read)
    end

    private

      attr_reader :doc
  end
end

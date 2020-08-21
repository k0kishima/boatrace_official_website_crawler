module V1707
  class EventHoldingParser
    CANCELED_TEXTS = %w(中止順延	中止)

    include HtmlParser

    def parse
      race_information_tbodies.map do |tbody|
        {
            stadium_tel_code: stadium_tel_code(tbody.elements.to_s),
            day_text:         canceled?(tbody.text) ? cancel_text(tbody.text) : day_text(tbody.text),
        }
      end
    end

    private

      def race_information_tbodies
        @race_information_tbodies ||= doc.search('.table1').first.search('table tbody')
      end

      def cancel_text(text)
        text.scan(/(#{CANCELED_TEXTS.join('|')})/).flatten.first
      end

      def stadium_tel_code(html_string)
        html_string.scan(/\?jcd=(\d{2})/).flatten.first.to_i
      end

      def canceled?(text)
        CANCELED_TEXTS.any? {|cancel_text| text.include?(cancel_text) }
      end

      def day_text(text)
        text.scan(/(初日|[\d１２３４５６７]日目|最終日)/).flatten.first
      end
  end
end
module V1707
  class RacerConditionParser
    include HtmlParser

    def parse
      attributes = []
      exhibition_rows.each_with_index do |row, i|
        next if absence?(row)

        attributes << {
          pit_number: i.next,
          racer_registration_number: racer_registration_number(row),
          weight: weight(row),
          adjust: adjust(row),
        }
      end
      attributes
    end

    private

      def exhibition_rows
        @exhibition_rows ||= doc.search('.table1')[1].search('tbody')
      end

      def weight(exhibition_row)
        exhibition_row.search('td')[3].text.to_f
      end

      def absence?(exhibition_row)
        exhibition_row.attribute('class').value.split(' ').include?('is-miss')
      end

      def adjust(exhibition_row)
        exhibition_row.search('td')[12].text.to_f
      end

      def racer_registration_number(exhibition_row)
        exhibition_row.search('td')[2].search('a').attribute('href').value.scan(/toban=(\d{4})$/).flatten.first.to_i
      end

      def pit_number(slit_row)
        slit_row.search('span')[0].text.to_i rescue nil
      end
  end
end
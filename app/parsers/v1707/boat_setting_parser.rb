module V1707
  class BoatSettingParser
    NEW_PROPELLER_MARK = '新'

    include HtmlParser

    def parse
      attributes = []
      exhibition_rows.each_with_index do |row, i|
        next if absence?(row)

        attributes << {
            pit_number: i.next,
            racer_registration_number: racer_registration_number(row),
            tilt: tilt(row),
            is_new_propeller: new_propeller?(row),
        }
      end
      attributes
    end

    private

      def exhibition_rows
        @exhibition_rows ||= doc.search('.table1')[1].search('tbody')
      end

      def absence?(exhibition_row)
        exhibition_row.attribute('class').value.split(' ').include?('is-miss')
      end

      def racer_registration_number(exhibition_row)
        exhibition_row.search('td')[2].search('a').attribute('href').value.scan(/toban=(\d{4})$/).flatten.first.to_i
      end

      def pit_number(slit_row)
        slit_row.search('span')[0].text.to_i rescue nil
      end

      def tilt(exhibition_row)
        exhibition_row.search('td')[5].text.to_f
      end

      def propeller(exhibition_row)
        exhibition_row.search('td')[6].text
      end

      def new_propeller?(exhibition_row)
        propeller(exhibition_row) == self.class::NEW_PROPELLER_MARK
      end
  end
end

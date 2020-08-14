module V1707
  class RaceExhibitionRecordParser
    include HtmlParser

    def parse
      attributes = []
      exhibition_rows.each_with_index do |row, i|
        next if absence?(row)

        attributes << {
            pit_number: i.next,
            racer_registration_number: racer_registration_number(row),
            exhibition_time:  exhibition_time(row),
        }

        sorted_exhibition_times = attributes.map{|a| a[:exhibition_time] }.sort
        attributes.each do |a|
          a[:exhibition_time_order] = sorted_exhibition_times.index(a[:exhibition_time])&.next
        end

        slit_rows.each_with_index do |row, i|
          next unless a = attributes.find{|a| a[:pit_number] == pit_number(row)}
          a[:start_course] = i.next
          a[:start_time] = formatted_start_time(row)
          a[:is_flying] = flying?(row)
        end
      end
      attributes
    end

    private

      def exhibition_rows
        @exhibition_rows ||= doc.search('.table1')[1].search('tbody')
      end

      def slit_rows
        @slit_rows ||= doc.search('.table1')[2].search('tbody tr')
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

      def exhibition_time(exhibition_row)
        exhibition_row.search('td')[4].text.to_f
      end

      def new_propeller?(exhibition_row)
        propeller(exhibition_row) == self.class::NEW_PROPELLER_MARK
      end

      def flying?(slit_row)
        html_classes = start_time_element(slit_row).attribute('class').value.split(' ')
        html_classes.include?('is-fBold')
      end

      def start_time_element(slit_row)
        slit_row.search('span').last
      end

      def start_time_text(slit_row)
        start_time_element(slit_row).text
      end

      def formatted_start_time(slit_row)
        text = start_time_text(slit_row)
        text.gsub!('F', '') if flying?(slit_row)
        text.to_f
      end

  end
end

module V1707
  class RaceEntryParser
    extend Memoist
    include HtmlParser

    def parse
      attributes = []
      racer_rows.each_with_index do |row, i|
        @current_row = row
        racer_names = racer_name.split(/[　　]+/).reverse
        attributes << {
            racer_registration_number: racer_registration_number,
            racer_first_name: racer_names.first,
            racer_last_name: racer_names.last,
            racer_rank: rank,
            pit_number: i.next,
            motor_number: motor_number,
            quinella_rate_of_motor: quinella_rate_of_motor,
            boat_number: boat_number,
            quinella_rate_of_boat:  quinella_rate_of_boat,
            whole_country_winning_rate: whole_country_winning_rate,
            local_winning_rate: local_winning_rate,
            whole_country_quinella_rate_of_racer: whole_country_quinella_rate_of_racer,
            whole_country_trio_rate_of_racer: whole_country_trio_rate_of_racer,
            local_quinella_rate_of_racer: local_quinella_rate_of_racer,
            local_trio_rate_of_racer: local_trio_rate_of_racer,
            is_absent: is_absent,
        }
      end
      attributes
    end

    private

    attr_reader :current_row

      def race_entry_table
        doc.search('.table1').last
      end
      memoize :race_entry_table

      def racer_rows
        race_entry_table.search('tbody')
      end
      memoize :racer_rows

      def racer_photo_path
        current_row.search('tr').first.search('td')[1].search('img').attribute('src').value
      end

      def racer_registration_number
        racer_photo_path.scan(/\/(\d+)\.jpe?g$/).flatten.first.to_i
      end

      def racer_name
        current_row.search('tr').first.search('td')[2].search('div a').text
      end

      def rank
        current_row.search('tr').first.search('td')[2].search('span').text
      end

      def motor_number
        current_row.search('tr').first.search('td')[6].children.first.text.scan(/(\d+)/).flatten.first.to_i
      end

      def quinella_rate_of_motor
        current_row.search('tr').first.search('td')[6].children[2].text.strip.to_f
      end

      def boat_number
        current_row.search('tr').first.search('td')[7].children.first.text.scan(/(\d+)/).flatten.first.to_i
      end

      def quinella_rate_of_boat
        current_row.search('tr').first.search('td')[7].children[2].text.strip.to_f
      end

      def whole_country_winning_rate
        current_row.search('tr').first.search('td')[4].children.first.text.strip.to_f
      end

      def local_winning_rate
        current_row.search('tr').first.search('td')[5].children.first.text.strip.to_f
      end

      def whole_country_quinella_rate_of_racer
        current_row.search('tr').first.search('td')[4].children[2].text.strip.to_f
      end

      def whole_country_trio_rate_of_racer
        current_row.search('tr').first.search('td')[4].children.last.text.strip.to_f
      end

      def local_quinella_rate_of_racer
        current_row.search('tr').first.search('td')[5].children[2].text.strip.to_f
      end

      def local_trio_rate_of_racer
        current_row.search('tr').first.search('td')[5].children.last.text.strip.to_f
      end

      def is_absent
        current_row.attribute('class').value.include?('is-miss')
      end
  end
end
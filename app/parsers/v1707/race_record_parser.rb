module V1707
  class RaceRecordParser
    module RACE_TIME_DELIMITER
      MINUTE = "'"
      SECOND = '"'
    end
    RACE_CANCELED_TEXT = 'レース中止'
    WINNING_TRICK_NAME_REGEXP = /(?:\p{Hiragana}|\p{Katakana}|[ー－]|[一-龠々])+/

    include HtmlParser

    def parse
      raise ::ParserError::RaceCanceled.new if canceled?

      @parsed_data = record_rows.map do |record_row|
        record = {
            pit_number:  color_on_record_table(record_row),
            time_minute: race_time_minute(record_row),
            time_second: race_time_second(record_row),
            start_course: nil,
            start_time: nil,
            winning_trick_name: nil,
        }
        arrival = arrival(record_row)
        if completed?(arrival)
          # 完走
          record[:arrival] = arrival.to_i
        else
          # 失格
          record[:arrival]               = nil
          record[:disqualification_mark] = arrival
        end
        record
      end

      start_time_rows.each_with_index do |start_time_row, i|
        # ※出遅れ or 欠場の場合はスタート情報を記録しない
        if record = saved_record(color_on_start_time_table(start_time_row))
          record[:start_course] = i.next
          record[:start_time]   = start_time(start_time_row)
        end

        record[:winning_trick_name] = winning_trick(start_time_row) if record[:arrival] == 1
      end

      sorted_start_times = parsed_data
                               .select{|hash| hash[:start_time].present? && hash[:disqualification_mark] != 'Ｆ' }
                               .sort_by{|hash| hash[:start_time] }
                               .map{|hash| hash[:start_time] }
      parsed_data.each do |hash|
        hash[:start_order] = sorted_start_times.index(hash[:start_time])&.next
      end

      parsed_data.sort_by{|hash| hash[:pit_number] }
    end

    private

      attr_reader :parsed_data

      def record_table
        @record_table ||= doc.search('.table1')[1]
      end

      def record_rows
        @record_rows ||= record_table.search('tbody')
      end

      def start_time_table
        @start_time_table ||= doc.search('.table1')[2]
      end

      def start_time_rows
        @start_time_rows ||= start_time_table.search('tbody tr')
      end

      def color_on_record_table(record_row)
        record_row.search('td')[1].text.to_i
      end

      def race_time_text(record_row)
        record_row.search('td')[3].text
      end

      def race_time_minute(record_row)
        race_time_text = race_time_text(record_row)
        return nil if race_time_text.blank?

        race_time_text.scan(/^(\d)/).flatten.first.to_i
      end

      def race_time_second(record_row)
        race_time_text = race_time_text(record_row)
        return nil if race_time_text.blank?

        race_time_text.scan(/^\d'([\d"]+)/).flatten.first.gsub(RACE_TIME_DELIMITER::SECOND, '.').to_f
      end

      def arrival(record_row)
        record_row.search('td')[0].text.tr('０-９', '0-9')
      end

      def completed?(arrival)
        arrival.match(/[1-6]{1}/)
      end

      def color_on_start_time_table(start_time_row)
        start_time_row.search('span').first.text.to_i
      end

      def saved_record(pit_number)
        parsed_data.find{|record| record[:pit_number] == pit_number }
      end

      def start_time(start_time_row)
        # Do not consider F here
        # Look Disqualification mark if judge F
        after_the_decimal_point = start_time_row.search('span').last.text.scan(/^F?\.(\d+)/).flatten.first
        "0.#{after_the_decimal_point}".to_f
      end

      def winning_trick(start_time_row)
        start_time_row.search('.table1_boatImage1TimeInner').text.scan(WINNING_TRICK_NAME_REGEXP).flatten.first
      end

      def canceled?
        doc.search('.l-main').text.match(/#{RACE_CANCELED_TEXT}/).present?
      end
  end
end

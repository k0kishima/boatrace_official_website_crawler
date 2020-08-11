module V1707
  class OddsParser
    RACE_CANCELED_TEXT = '該当レースは中止になりました'
    DATA_NOT_FOUND_TEXT = 'データはありません'

    include HtmlParser

    def parse
      raise ::ParserError::RaceCanceled.new if canceled?
      raise ::ParserError::DataNotFound.new if unexist?

      odds = []
      odds_cells.each_with_index do |odds_cell, i|
        betting_number = [first_arrived(i), second_arrived(i), third_arrived(i)].join
        odds << { betting_number: betting_number.to_i, ratio:  odds_cell.text.to_f }
      end
      odds
    end

    private

      def odds_table
        @odds_table ||= doc.search('.table1')[1]
      end

      def odds_cells
        @odds_cells ||= odds_table.search('tbody tr td.oddsPoint')
      end

      def second_arrived_cells
        @second_arrived_cells ||= odds_table.search('tbody tr td[rowspan="4"]')
      end

      def second_arrived_numbers
        @second_arrived_numbers ||= second_arrived_cells.map(&:text).each_slice(6).to_a.map{|numbers| numbers * 4 }.flatten
      end

      def second_arrived(loop_offset)
        second_arrived_numbers[loop_offset]
      end

      def third_arrived_cells
        @third_arrived_cells ||= odds_table.search('tbody tr td[class^="is-boatColor"]')
      end

      def third_arrived(loop_offset)
        third_arrived_cells.map(&:text)[loop_offset]
      end

      def closed?
        doc.search('p.tab4_time').present?
      end

      def status
        closed? ? :closed : :open
      end

      def bet_method
        case odds_table.search('tbody tr td.oddsPoint').count
        when 120
          '3permutation'
        end
      end

      def first_arrived(loop_offset)
        raise NotImplementedError.new unless bet_method == '3permutation'
        (loop_offset % 6).next
      end

      def canceled?
        doc.search('.l-main').text.match(/#{RACE_CANCELED_TEXT}/).present?
      end

      def unexist?
        doc.search('.l-main').text.match(/#{DATA_NOT_FOUND_TEXT}/).present?
      end
  end
end
module V1707
  class RaceParser
    include HtmlParser

    module TEXT
      COURSE_FIXED = '進入固定'
      USE_STABILIZER = '安定板使用'
    end

    def parse
      {
          number: race_number,
          is_course_fixed: course_fixed?,
          use_stabilizer: use_stabilizer?,
          deadline:        deadline_text,
          title:           title,
          metre:           metre,
      }
    end

    private

      def course_fixed?
        doc.search('.label2.is-type1').select{|label| label.text == TEXT::COURSE_FIXED }.present?
      end

      def deadline_table
        @deadline_table ||= doc.search('.table1').first
      end

      def race_number
        @race_number ||= deadline_table.search('tr th[class=""]').text.to_i
      end

      def outside_deladline_rows
        @outside_deladline_rows ||= deadline_table.search('tbody tr').last
      end

      def deadline_text
        outside_deladline_rows.search('td')[race_number].text
      end

      def title
        doc.search('.heading2_titleDetail').text.scan(/([^\n]+)\n/).flatten.first.strip.gsub(/[　 ]+/, '')
      end

      def metre
        doc.search('.heading2_titleDetail').text.scan(/(\d{3,4}m)/).flatten.first.to_i
      end

      def use_stabilizer?
        doc.search('.label2.is-type1').select{|label| label.text == TEXT::USE_STABILIZER }.present?
      end
  end
end

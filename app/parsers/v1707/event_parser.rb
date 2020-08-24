module V1707
  class EventParser
    extend Memoist
    include HtmlParser

    def parse
      attributes = []

      schedule_rows.each_with_index do |schedule_row, index|
        stadium_tel_code = index.next
        date_pointer = offset_day

        schedule_row.search('td').each do |series_cell|
          break if date.end_of_month < date_pointer

          series_days = series_cell.attribute('colspan').try(:value).to_i
          if series_days.zero?
            date_pointer = date_pointer.next_day
            next
          end

          if date <= date_pointer
            attributes << {
                stadium_tel_code: stadium_tel_code,
                title:            series_cell.text,
                starts_on:        date_pointer,
                days:             series_days,
                # hack: ここでは単純にパースだけを行い、gradeやkindはファクトリでenum生成みたいな方がよさそう
                grade:            grade_by(html_class: series_cell.attribute('class').value, title: series_cell.text).downcase,
                kind:             kind_by(html_class: series_cell.attribute('class').value, title: series_cell.text).downcase,
            }
          end

          date_pointer += series_days.days
        end
      end

      attributes
    end

    private

      def prev_year_month_params_value
        doc.search('li.title2_navsLeft a').attribute('href').value.match(/\?ym=(\d{6})/)
        $1
      end
      memoize :prev_year_month_params_value

      def prev_year
        prev_year_month_params_value[0..3].to_i
      end
      memoize :prev_year

      def prev_month
        prev_year_month_params_value[4..5].to_i
      end
      memoize :prev_month

      def prev_calender_date
        Date.new(prev_year, prev_month)
      end
      memoize :prev_calender_date

      def date
        prev_calender_date.next_month
      end
      memoize :date

      def calender_row
        doc.search('table thead tr').first
      end
      memoize :calender_row

      def schedule_rows
        doc.search('table.is-spritedNone1 tbody tr')
      end
      memoize :schedule_rows

      def start_day
        calender_row.search('th')[1].text.to_i
      end
      memoize :start_day

      def offset_day
        (start_day == 1) ? date : date.prev_month.change(day: start_day)
      end
      memoize :offset_day

      def grade_by(html_class: , title:)
        grade = case html_class
                when 'is-gradeColorSG'
                  'SG'
                when 'is-gradeColorG1'
                  'G1'
                when 'is-gradeColorG2'
                  'G2'
                when 'is-gradeColorG3'
                  'G3'
                end

        return grade if grade.present?

        match = title.tr('ＧⅠⅡⅢ１２３', 'G123123').match(/G[1-3]{1}/)
        if match.present?
          match[0]
        else
          'no_grade'
        end
      end

      def kind_by(html_class: , title:)
        kind = case html_class
               when 'is-gradeColorRookie'
                 'rookie'
               when 'is-gradeColorVenus'
                 'venus'
               when 'is-gradeColorLady'
                 'all_ladies'
               when 'is-gradeColorTakumi'
                 'senior'
               end
        return kind if kind.present?
        return 'double_winner' if title.match(/男女[wWwＷ]優勝戦/)
        'uncategorized'
      end

  end
end

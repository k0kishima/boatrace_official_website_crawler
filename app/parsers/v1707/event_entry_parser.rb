module V1707
  class EventEntryParser
    SERIES_CANCELED_TEXT = '※ データはありません。'

    include HtmlParser

    # NOTE:
    #
    # このバージョンの公式サイトだと、このパーサーが処理するページ（前検結果）からしかレーサーの性別が取得できない
    # (プロフィールも出走表も写真があるから人間であれば一目でわかるから性別を記載していない？)
    # 性別以外は使う項目はないのだがそういう事情があるので実装を残している
    #
    # なのでここで取得できなかった性別は当面は運用カバーで手動更新
    # TODO: ↑運用カバーでなんとかしない
    def parse
      raise ::ParserError::DataNotFound.new if canceled?

      series_entry_rows.map do |row|
        cells = row.search('td')
        racer_names = cells[2].text.strip.split(/[　　]+/).reverse
        {
            racer_registration_number:             cells[1].text.to_i,
            racer_first_name: racer_names.first,
            racer_last_name: racer_names.last,
            racer_rank:                            cells[3].text,
            motor_number:                          cells[4].text.to_i,
            quinella_rate_of_motor:                cells[5].text.to_f,
            boat_number:                           cells[6].text.to_i,
            quinella_rate_of_boat:                 cells[7].text.to_f,
            anterior_time:                         cells[8].text.to_f,
            racer_gender: row.search('.is-lady').present? ? 'female' : 'male'
        }
      end
    end

    private

      def series_entry_rows
        @series_entry_rows ||= doc.search('.table1 table tbody tr')
      end

      def canceled?
        doc.search('.l-main').text.match(/#{SERIES_CANCELED_TEXT}/).present?
      end
  end
end
module V1707
  class PayoffParser
    SIMULTANEOUS_TEXT = '同着あり'
    SPECIAL_PAY_TEXT  = '特払い'

    include HtmlParser

    def parse
      attributes = []
      number_and_amount_pairs(trifecta_tbody).compact.each do |attribute|
        attributes << { betting_method: :trifecta, betting_number: attribute[:betting_number], amount: attribute[:amount] }
      end
      attributes
    end

    private

    def payment_table
      @payment_table ||= doc.search('.table1')[3]
    end

    def trifecta_tbody
      @trifecta_tbody ||= payment_table.search('tbody')[0]
    end

    def number_and_amount_pairs(tbody)
      rowspan = tbody.search('td').first.attribute('rowspan').value

      tbody.search('tr').map do |tr|
        tds = tr.search('td:not([rowspan="' + rowspan + '"])')

        betting_number = tds[0].search('span.numberSet1_number').map(&:text).map(&:to_i).join('-')
        amount  = tds[1].text.gsub(/[^0-9]/,'').to_i

        { betting_number: betting_number, amount: amount, } if betting_number.present?
      end
    end
  end
end

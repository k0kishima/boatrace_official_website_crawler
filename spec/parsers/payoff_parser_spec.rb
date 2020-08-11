require 'rails_helper'

describe 'race payoff parsing' do
  context 'in version 1707' do
    subject { parser.parse }

    let(:parser_class) { V1707::PayoffParser }
    let(:parser) { parser_class.new(File.new(file_path, 'r')) }
    let(:parsed_data) { subject }

    context '返還がないとき' do
      let(:file_path) { "#{Rails.root}/spec/fixtures/files/v1707/race_result/2015_11_15_07#_12R.html" }

      it '勝舟番号と払戻金がパースされること' do
        expect(subject).to eq([ {betting_method: :trifecta, betting_number: "4-3-5", amount: 56670}, ])
      end
    end

    context '欠場艇がいるとき' do
      let(:file_path) { "#{Rails.root}/spec/fixtures/files//v1707/race_result/2015_11_16_03#_11R.html" }

      it '勝舟番号と払戻金がパースされること' do
        expect(subject).to eq([ {betting_method: :trifecta, betting_number: "2-3-4", amount: 3100}, ])
      end
    end

    context '2連単以外の式別が不成立のとき' do
      let(:file_path) { "#{Rails.root}/spec/fixtures/files/v1707/race_result/2015_11_14_02#_2R.html" }

      it { is_expected.to be_blank }
    end
  end
end

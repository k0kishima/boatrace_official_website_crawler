require 'rails_helper'

describe 'odds parsing' do
  context 'in version 1707' do
    subject { parser.parse }

    let(:parser_class) { V1707::OddsParser }
    let(:parser) { parser_class.new(File.new(file_path, 'r')) }

    context 'レースが中止されたとき' do
      let(:file_path) { "#{Rails.root}/spec/fixtures/files/v1707/odds/trifecta/2018_01_03_03#_11R.html" }

      it { expect{ subject }.to raise_error(::ParserError::RaceCanceled) }
    end

    context 'データが公開されていないとき' do
      let(:file_path) { "#{Rails.root}/spec/fixtures/files/v1707/odds/trifecta/2017_01_02_01#_1R.html" }

      it { expect{ subject }.to raise_error(::ParserError::DataNotFound) }
    end

    context '3連単をパースするとき' do
      let(:file_path) { "#{Rails.root}/spec/fixtures/files/v1707/odds/trifecta/2017_09_19_19#_11R.html" }

      it 'オッズがパースされること' do
        parsed_data = subject
        expect(parsed_data.count).to eq 120
        expect(parsed_data.first).to eq({ betting_number: 123,  ratio: 6.1, })
      end

      it '欠場艇はnilになること' do
        parsed_data = subject
        expect(parsed_data.last).to eq({ betting_number: 654, ratio: 0.0, })
      end
    end
  end
end

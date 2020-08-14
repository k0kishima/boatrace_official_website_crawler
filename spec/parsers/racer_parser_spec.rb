require 'rails_helper'

describe 'racer parsing' do
  context 'in version 1707' do
    subject { parser.parse }

    let(:parser_class) { V1707::RacerParser }
    let(:parser) { parser_class.new(File.new(file_path, 'r')) }

    context 'when active working racer file given' do
      # NOTE
      # このファイルは2020/08/10 に更新したものです
      # 級別はファイルダウンロードしたときの適用期間によって変わる可能性があります
      # あと体重と場合によっては身長も変わります
      let(:file_path) { "#{Rails.root}/spec/fixtures/files/v1707/racer/4444/profile.html" }

      it 'parses racer profile' do
        expect(subject).to eq ({
            :last_name=>"桐生",
            :first_name=>"順平",
            :registration_number=>4444,
            :birth_date=>Date.new(1986, 10, 7),
            :height=>160,
            :weight=>52,
            :branch_prefecture=>"埼玉",
            :born_prefecture=>"福島県",
            :term=>100,
            :current_rating=>"A1級",
        })
      end

      context 'when retired racer file given' do
        let(:file_path) { "#{Rails.root}/spec/fixtures/files/v1707/racer/retired.htm" }

        it 'raise an exception' do
          expect { subject }.to raise_error(::ParserError::DataNotFound)
        end
      end
    end
  end
end

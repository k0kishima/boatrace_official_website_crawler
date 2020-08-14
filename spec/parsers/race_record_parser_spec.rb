require 'rails_helper'

describe 'race record parsing' do
  context 'in version 1707' do
    subject { parser.parse }

    let(:parser_class) { V1707::RaceRecordParser }
    let(:parser) { parser_class.new(File.new(file_path, 'r')) }
    let(:parsed_data) { subject }

    context 'レースが中止されたとき' do
      let(:file_path) { "#{Rails.root}/spec/fixtures/files/v1707/race_result/2018_08_05_03#_8R.html" }

      it { expect{ subject }.to raise_error(::ParserError::RaceCanceled) }
    end

    context '失格があったとき' do
      context 'フライングがあったとき' do
        let(:file_path) { "#{Rails.root}/spec/fixtures/files/v1707/race_result/2015_11_14_02#_2R.html" }

        it 'フライングの失格記号がパースされること' do
          expect(parsed_data.map{|v| v[:disqualification_mark] }).to eq [nil, nil, 'Ｆ', 'Ｆ', 'Ｆ', 'Ｆ']
        end

        it 'フライング艇のSTもパースされること' do
          expect(parsed_data.map{|v| v[:start_time] }).to eq [0.35, 0.11, 0.01, 0.01, 0.01, 0.01]
        end

        it 'フライング艇を除いてスタート順がパースされること' do
          expect(parsed_data.map{|v| v[:start_order] }).to eq [2, 1, nil, nil, nil, nil]
        end
      end

      context '出遅れがあったとき' do
        let(:file_path) { "#{Rails.root}/spec/fixtures/files/v1707/race_result/2015_11_16_09#_7R.html" }

        it '失格記号がパースされること' do
          expect(parsed_data.map{|v| v[:disqualification_mark] }).to eq [nil, 'Ｌ', nil, nil, nil, nil]
        end

        # パースされないっていうよりはパースできない
        # http://boatrace.jp/owpc/pc/race/raceresult?rno=7&jcd=09&hd=20151116
        it '出遅れた艇のスタート情報（進入コース・STなど）はパースされないこと' do
          expect(parsed_data[1]).to eq({:arrival=>nil, :disqualification_mark=>"Ｌ", :pit_number=>2, :start_course => nil, :start_order => nil, :start_time=>nil, :time_minute=>nil, :time_second=>nil, :winning_trick_name=>nil})
        end

        it '出遅れた艇のスタート順はパースされないこと' do
          expect(parsed_data.map{|v| v[:start_order] }).to eq [1, nil, 4, 3, 5, 2]
        end
      end

      context '妨害・落水があったとき' do
        let(:file_path) { "#{Rails.root}/spec/fixtures/files/v1707/race_result/2015_11_18_11#_1R.html" }

        it '失格記号がパースされること' do
          expect(parsed_data.map{|v| v[:disqualification_mark] }).to eq [nil, '妨', '落', nil, nil, nil]
        end

        it '失格艇のスタート順はパースされること' do
          expect(parsed_data.map{|v| v[:start_order] }).to eq [1, 3, 6, 2, 5, 4]
        end
      end

      context 'その他スタート後の失格があったとき' do
        let(:file_path) { "#{Rails.root}/spec/fixtures/files/v1707/race_result/2015_11_18_10#_1R.html" }

        it '失格記号がパースされること' do
          expect(parsed_data.map{|v| v[:disqualification_mark] }).to eq [nil, nil, '失', nil, nil, nil]
        end

        it '失格艇のスタート順はパースされること' do
          # 1が2つあるのは同じSTだったから（1号艇と6号艇がトップスタートした）
          expect(parsed_data.map{|v| v[:start_order] }).to eq [1, 6, 5, 3, 4, 1]
        end
      end
    end

    context '欠場艇がいるとき' do
      let(:file_path) { "#{Rails.root}/spec/fixtures/files/v1707/race_result/2015_11_16_09#_9R.html" }

      it '失格記号がパースされること' do
        expect(parsed_data.map{|v| v[:disqualification_mark] }).to eq [nil, '欠', nil, nil, nil, nil]
      end

      it '欠場艇の進入コースはパースされること' do
        expect(parsed_data[1]).to eq({:arrival=>nil, :disqualification_mark=>"欠", :pit_number=>2, :start_course=>nil, :start_time=>nil, :start_order => nil, :time_minute=>nil, :time_second=>nil, :winning_trick_name=>nil})
      end

      it '欠場艇のスタート順はパースされないこと' do
        expect(parsed_data.map{|v| v[:start_order] }).to eq [5, nil, 4, 3, 2, 1]
      end
    end

    context '同着のとき' do
      let(:file_path) { "#{Rails.root}/spec/fixtures/files/v1707/race_result/2018_11_16_18#_7R.html" }

      it '決まり手が複数パースされること' do
        winner_records = parsed_data.select{|record| record[:arrival] == 1 }
        loser_records = parsed_data - winner_records

        expect(winner_records.count).to eq 2
        winner_records.each do |winner_record|
          expect(winner_record.fetch(:winning_trick_name)).to be_present
        end
        loser_records.each do |loser_record|
          expect(loser_record.fetch(:winning_trick_name)).to be_blank
        end
      end
    end

    context '集団Fで不成立のレース' do
      let(:file_path) { "#{Rails.root}/spec/fixtures/files/v1707/race_result/2019_01_27_21#_7R.html" }

      it '記号がパースされること' do
        expect(parsed_data.map{|v| v[:disqualification_mark] }).to eq ['＿', 'Ｆ', 'Ｆ', 'Ｆ', 'Ｆ', 'Ｆ']
      end

      it 'フライング艇のSTもパースされること' do
        expect(parsed_data.map{|v| v[:start_time] }).to eq [0.01, 0.01, 0.02, 0.02, 0.04, 0.04]
      end
    end
  end
end

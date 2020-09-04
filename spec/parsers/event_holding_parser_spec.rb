require 'rails_helper'

describe 'event holding parsing' do
  context 'in version 1707' do
    subject { parser.parse }

    let(:parser_class) { V1707::EventHoldingParser }
    let(:parser) { parser_class.new(File.new(file_path, 'r')) }

    context '全レースが終了しているとき' do
      context '中止や順延が発生しているとき' do
        let(:file_path) { "#{Rails.root}/spec/fixtures/files/v1707/event_holding/2015_08_25.html" }

        it '中止や順延を含めた開催情報がパースされること' do
          expect(subject).to eq [
              { stadium_tel_code: 3,  day_text: '３日目'  },
              { stadium_tel_code: 4,  day_text: '最終日' },
              { stadium_tel_code: 7,  day_text: '初日'   },
              { stadium_tel_code: 11, day_text: '５日目'  },
              { stadium_tel_code: 16, day_text: '中止順延'},
              { stadium_tel_code: 18, day_text: '中止順延'},
              { stadium_tel_code: 19, day_text: '中止'   },
              { stadium_tel_code: 20, day_text: '中止順延'},
              { stadium_tel_code: 22, day_text: '中止順延'},
              { stadium_tel_code: 23, day_text: '中止順延'},
              { stadium_tel_code: 24, day_text: '中止'   }
          ]
        end
      end

      context 'nR目以降が中止になっているとき' do
        let(:file_path) { "#{Rails.root}/spec/fixtures/files/v1707/event_holding/2020_08_13.html" }

        it '途中から中止になった節は開催されているものとしてパースされること' do
          expect(subject).to eq [
              {:stadium_tel_code=>1, :day_text=>"初日"},
              {:stadium_tel_code=>2, :day_text=>"３日目"},
              {:stadium_tel_code=>3, :day_text=>"初日"},
              {:stadium_tel_code=>6, :day_text=>"初日"},
              {:stadium_tel_code=>7, :day_text=>"初日"},
              {:stadium_tel_code=>10, :day_text=>"最終日"},
              {:stadium_tel_code=>11, :day_text=>"最終日"},
              {:stadium_tel_code=>12, :day_text=>"中止"},
              {:stadium_tel_code=>13, :day_text=>"５日目"},
              {:stadium_tel_code=>14, :day_text=>"３日目"},
              {:stadium_tel_code=>17, :day_text=>"２日目"},
              {:stadium_tel_code=>18, :day_text=>"初日"},
              {:stadium_tel_code=>20, :day_text=>"４日目"},
              {:stadium_tel_code=>22, :day_text=>"３日目"},
              {:stadium_tel_code=>23, :day_text=>"３日目"}
          ]
        end
      end
    end

    context '発売中のレースがあるとき' do
      let(:file_path) { "#{Rails.root}/spec/fixtures/files/v1707/event_holding/2018_05_23.html" }

      it 'パースできること' do
        expect(subject).to eq [
            {:stadium_tel_code=>1, :day_text=>'最終日'},
            {:stadium_tel_code=>2, :day_text=>'２日目'},
            {:stadium_tel_code=>7, :day_text=>'５日目'},
            {:stadium_tel_code=>8, :day_text=>'最終日'},
            {:stadium_tel_code=>10, :day_text=>'初日'},
            {:stadium_tel_code=>13, :day_text=>'２日目'},
            {:stadium_tel_code=>14, :day_text=>'４日目'},
            {:stadium_tel_code=>15, :day_text=>'初日'},
            {:stadium_tel_code=>16, :day_text=>'最終日'},
            {:stadium_tel_code=>17, :day_text=>'３日目'},
            {:stadium_tel_code=>18, :day_text=>'４日目'},
            {:stadium_tel_code=>20, :day_text=>'３日目'},
            {:stadium_tel_code=>22, :day_text=>'２日目'},
            {:stadium_tel_code=>24, :day_text=>'５日目'}
        ]
      end
    end

    context '前売りのレースがあるとき' do
      let(:file_path) { "#{Rails.root}/spec/fixtures/files/v1707/event_holding/pre_sale_presents.html" }

      it 'パースできること' do
        expect(subject).to eq [
            {:stadium_tel_code=>1, :day_text=>"最終日"},
            {:stadium_tel_code=>2, :day_text=>"４日目"},
            {:stadium_tel_code=>6, :day_text=>"４日目"},
            {:stadium_tel_code=>7, :day_text=>"２日目"},
            {:stadium_tel_code=>8, :day_text=>"初日"},
            {:stadium_tel_code=>10, :day_text=>"初日"},
            {:stadium_tel_code=>11, :day_text=>"最終日"},
            {:stadium_tel_code=>13, :day_text=>"４日目"},
            {:stadium_tel_code=>14, :day_text=>"最終日"},
            {:stadium_tel_code=>16, :day_text=>"３日目"},
            {:stadium_tel_code=>17, :day_text=>"５日目"},
            {:stadium_tel_code=>19, :day_text=>"初日"},
            {:stadium_tel_code=>20, :day_text=>"４日目"},
            {:stadium_tel_code=>23, :day_text=>"最終日"}
        ]
      end
    end
  end
end
require 'rails_helper'

describe 'weather condition parsing' do
  context 'in version 1707' do
    subject { parser.parse }

    let(:parser_class) { V1707::WeatherConditionParser }
    let(:parser) { parser_class.new(File.new(file_path, 'r')) }

    context '直前情報のページが与えられたとき' do
      context '情報が欠損している時' do
        context '0:00時点の観測結果のとき' do
          let(:file_path) { "#{Rails.root}/spec/fixtures/files/v1707/race_before_information/2017_10_30_03#_1R.html" }

          it { expect{ subject }.to raise_error(::ParserError::DataNotFound) }
        end

        context 'レースが中止されているとき' do
          let(:file_path) { "#{Rails.root}/spec/fixtures/files/v1707/race_before_information/2017_10_30_03#_9R.html" }

          it { expect{ subject }.to raise_error(::ParserError::DataNotFound) }
        end
      end

      context '異常気象ではないとき' do
        let(:file_path) { "#{Rails.root}/spec/fixtures/files/v1707/race_before_information/2015_11_15_07#_12R.html" }
        it '水面気象情報がパースされること' do
          expect(subject).to eq({
                                        weather:          '晴',
                                        wavelength:       '2cm',
                                        wind_angle:        315.0,
                                        wind_velocity:     '4m',
                                        air_temperature:   '17.0℃',
                                        water_temperature: '17.0℃',
                                    })
        end
      end

      context '台風のとき' do
        let(:file_path) { "#{Rails.root}/spec/fixtures/files/v1707/race_before_information/2017_10_22_07#_1R.html" }

        it 'パースできること' do
          expect{ subject }.to_not raise_error(::ParserError::UnknownDataDetected)
        end
      end
    end

    context 'レース結果のページが与えられたとき' do
      let(:file_path) { "#{Rails.root}/spec/fixtures/files/v1707/race_result/2018_11_16_18#_7R.html" }

      it 'パースできること' do
        expect(subject).to eq({
                                             weather: "曇り",
                                             wavelength: "1cm",
                                             wind_angle: 135.0,
                                             wind_velocity: "1m",
                                             air_temperature: "15.0℃",
                                             water_temperature: "18.0℃"
                                         })
      end
    end

    context 'レースが中止されたとき' do
      let(:file_path) { "#{Rails.root}/spec/fixtures/files/v1707/race_result/2018_08_05_03#_8R.html" }

      it { expect{ subject }.to raise_error(::ParserError::RaceCanceled) }
    end
  end
end

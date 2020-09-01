require 'rails_helper'

describe 'boat setting parsing' do
  context 'in version 1707' do
    subject { parser.parse }

    let(:parser_class) { V1707::BoatSettingParser }
    let(:parser) { parser_class.new(File.new(file_path, 'r')) }

    context '欠場艇がいないとき' do
      let(:file_path) { "#{Rails.root}/spec/fixtures/files/v1707/race_before_information/2015_11_16_23#_1R.html" }

      it '全艇パースされること' do
        parsed_data = subject
        expect(parsed_data.count).to eq 6
        expect(parsed_data.first).to eq({
                                            pit_number:       1,
                                            racer_registration_number: 4096,
                                            tilt:             -0.5,
                                            is_new_propeller: false,
                                        })
        expect(parsed_data.last).to eq({
                                           pit_number:       6,
                                           racer_registration_number: 4221,
                                           tilt:             -0.5,
                                           is_new_propeller: false,
                                       })
      end

      context '欠場艇が存在するとき' do
        let(:file_path) { "#{Rails.root}/spec/fixtures/files/v1707/race_before_information/2015_11_16_03#_11R.html" }

        it '欠場艇を除いてパースされること' do
          parsed_data = subject
          expect(parsed_data.count).to eq 5
          expect(parsed_data.first).to eq({
                                              pit_number:       2,
                                              racer_registration_number: 3880,
                                              tilt:             0.0,
                                              is_new_propeller: false,
                                          })
          expect(parsed_data.last).to eq({
                                             pit_number:       6,
                                             racer_registration_number: 3797,
                                             tilt:             0.5,
                                             is_new_propeller: false,
                                         })
        end

      end

      context 'プロペラの変更があるとき' do
        let(:file_path) { "#{Rails.root}/spec/fixtures/files/v1707/race_before_information/2018_06_19_04#_4R.html" }

        it 'プロペラの変更も含めてパースされること' do
          expect(subject.map{|d| d[:is_new_propeller] }).to eq([false, false, false, true, false, false])
        end
      end

      context '情報が不完全な場合' do
        let(:file_path) { "#{Rails.root}/spec/fixtures/files/v1707/race_before_information/2020_06_30_12#_12R.html" }

        it 'raises data not found exception' do
          expect { subject }.to raise_error(::ParserError::DataNotFound)
        end
      end
    end
  end
end

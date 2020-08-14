require 'rails_helper'

describe 'racer condition parsing' do
  context 'in version 1707' do
    subject { parser.parse }

    let(:parser_class) { V1707::RacerConditionParser }
    let(:parser) { parser_class.new(File.new(file_path, 'r')) }

    context '欠場艇がいないとき' do
      let(:file_path) { "#{Rails.root}/spec/fixtures/files/v1707/race_before_information/2015_11_16_23#_1R.html" }

      it '全艇パースされること' do
        parsed_data = subject
        expect(parsed_data.count).to eq 6
        expect(parsed_data.first).to eq({
                                            pit_number:       1,
                                            racer_registration_number: 4096,
                                            weight:           52.5,
                                            adjust:           0.0,
                                        })
        expect(parsed_data.last).to eq({
                                           pit_number:       6,
                                           racer_registration_number: 4221,
                                           weight:           50.0,
                                           adjust:           1.0,
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
                                              weight:           55.8,
                                              adjust:           0.0,
                                          })
          expect(parsed_data.last).to eq({
                                             pit_number:       6,
                                             racer_registration_number: 3797,
                                             weight:           58.3,
                                             adjust:           0.0,
                                         })
        end

      end
    end
  end
end

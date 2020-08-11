require 'rails_helper'

describe 'race exhibition record parsing' do
  context 'in version 1707' do
    subject { parser.parse }

    let(:parser_class) { V1707::RaceExhibitionRecordParser }
    let(:parser) { parser_class.new(File.new(file_path, 'r')) }

    context '欠場艇がいないとき' do
      let(:file_path) { "#{Rails.root}/spec/fixtures/files/v1707/race_before_information/2015_11_16_23#_1R.html" }

      it '全艇パースされること' do
        parsed_data = subject
        expect(parsed_data.count).to eq 6
        expect(parsed_data.first).to eq({
                                            pit_number:       1,
                                            racer_registration_number: 4096,
                                            exhibition_time:  6.7,
                                            exhibition_time_order:  1,
                                            start_course:     1,
                                            start_time:       0.23,
                                            is_flying:        false
                                        })
        expect(parsed_data.last).to eq({
                                           pit_number:       6,
                                           racer_registration_number: 4221,
                                           exhibition_time:  6.81,
                                           exhibition_time_order:  2,
                                           start_course:     6,
                                           start_time:       0.04,
                                           is_flying:        true
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
                                              exhibition_time:  6.91,
                                              exhibition_time_order: 2,
                                              start_course:     1,
                                              start_time:       0.21,
                                              is_flying:        false
                                          })
          expect(parsed_data.last).to eq({
                                             pit_number:       6,
                                             racer_registration_number: 3797,
                                             exhibition_time:  6.78,
                                             exhibition_time_order: 1,
                                             start_course:     5,
                                             start_time:       0.32,
                                             is_flying:        false
                                         })
        end
      end
    end
  end
end
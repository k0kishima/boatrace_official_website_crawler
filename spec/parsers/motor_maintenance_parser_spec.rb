require 'rails_helper'

describe 'motor maintenance record parsing' do
  context 'in version 1707' do
    subject { parser.parse }

    let(:parser_class) { V1707::MotorMaintenanceParser }
    let(:parser) { parser_class.new(File.new(file_path, 'r')) }

    context '欠場艇がいないとき' do
      let(:file_path) { "#{Rails.root}/spec/fixtures/files/v1707/race_before_information/2015_11_16_23#_1R.html" }

      it '全艇パースされること' do
        parsed_data = subject
        expect(parsed_data.count).to eq 6
        expect(parsed_data.first).to eq({
                                            pit_number:       1,
                                            racer_registration_number: 4096,
                                            parts_exchanges:  [],
                                        })
        expect(parsed_data.last).to eq({
                                           pit_number:       6,
                                           racer_registration_number: 4221,
                                           parts_exchanges:  [],
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
                                              parts_exchanges:  [],
                                          })
          expect(parsed_data.last).to eq({
                                             pit_number:       6,
                                             racer_registration_number: 3797,
                                             parts_exchanges:  [],
                                         })
        end
      end

      context 'モーターの部品交換があるとき' do
        let(:file_path) { "#{Rails.root}/spec/fixtures/files/v1707/race_before_information/2015_11_16_23#_12R.html" }

        it '部品交換情報も含めてパースされること' do
          expect(subject.fifth).to eq({
                                        pit_number:       5,
                                        racer_registration_number: 3963,
                                        parts_exchanges: [
                                            { parts_name: 'ピストン', count: 2 },
                                            { parts_name: 'リング',   count: 3 },
                                            { parts_name: '電気',     count: 1 },
                                            { parts_name: 'ギヤ',     count: 1 }
                                        ],
                                    })
        end
      end
    end
  end
end

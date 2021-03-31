# frozen_string_literal: true

RSpec.describe Xminds::ResponseError do
  let(:http_status_code) { Faker::Number.between(from: 400, to: 599) }
  let(:message) do
    {
      error_code: Faker::Number.between(from: 1, to: 100),
      error_name: Faker::Color.color_name,
      message: Faker::Lorem.sentence,
      error_data: {
        type: Faker::Team.state,
        key: Faker::Team.sport,
        name: Faker::Team
      }
    }
  end

  describe '#initialize' do
    it 'sets the needed instance variables and passes the message to super' do
      error = described_class.new(http_status_code: http_status_code, message: message)

      expect(error.http_status_code).to eq(http_status_code)
      expect(error.error_code).to eq(message[:error_code])
      expect(error.error_name).to eq(message[:error_name])
      expect(error.error_message).to eq(message[:message])
      expect(error.error_data).to eq(message[:error_data])
      expect(error.message).to eq(JSON.generate(message))
    end
  end
end

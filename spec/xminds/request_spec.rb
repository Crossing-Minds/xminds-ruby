# frozen_string_literal: true

RSpec.describe Xminds::Request do
  describe '#initialize' do
    let(:endpoint) { Faker::Internet.url }
    let(:jwt_token) { Faker::Alphanumeric.alphanumeric }

    it 'sets the endpoint and jwt_token' do
      req = described_class.new(endpoint: endpoint, jwt_token: jwt_token)

      expect(req.instance_variable_get(:@endpoint)).to eq(endpoint)
      expect(req.instance_variable_get(:@jwt_token)).to eq(jwt_token)
    end
  end
end

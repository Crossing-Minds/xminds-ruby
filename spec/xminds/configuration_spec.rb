# frozen_string_literal: true

RSpec.describe Xminds::Configuration do
  let(:endpoint) { Faker::Internet.url }
  let(:password) { Faker::Internet.password }
  let(:email) { Faker::Internet.email }
  let(:database_id) { "DATABASE_ID-#{Faker::Alphanumeric.alphanumeric(number: 6)}" }
  let(:service_name) { "SERVICE_NAME-#{Faker::Alphanumeric.alphanumeric(number: 6)}" }
  let(:frontend_user_id) { Faker::Number.number.to_s }

  describe '#initialize' do
    before do
      allow(ENV).to receive(:fetch).with('XMINDS_API_ENDPOINT', 'https://api.crossingminds.com/').and_return(endpoint)
      allow(ENV).to receive(:[]).with('XMINDS_API_EMAIL').and_return(email)
      allow(ENV).to receive(:[]).with('XMINDS_API_PWD').and_return(password)
      allow(ENV).to receive(:[]).with('XMINDS_API_DATABASE_ID').and_return(database_id)
      allow(ENV).to receive(:[]).with('XMINDS_API_SERVICE_NAME').and_return(service_name)
      allow(ENV).to receive(:key?).with('XMINDS_API_FRONTEND_USER_ID').and_return(true)
      allow(ENV).to receive(:[]).with('XMINDS_API_FRONTEND_USER_ID').and_return(frontend_user_id)
    end

    it 'defaults config values to environment variables' do
      config = described_class.new

      expect(config.endpoint).to eq(endpoint)
      expect(config.email).to eq(email)
      expect(config.password).to eq(password)
      expect(config.database_id).to eq(database_id)
      expect(config.service_name).to eq(service_name)
      expect(config.frontend_user_id).to eq(frontend_user_id)
    end
  end
end

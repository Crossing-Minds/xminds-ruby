# frozen_string_literal: true

RSpec.describe Xminds::Client do
  let(:authentication_double) do
    double(
      :authentication_double,
      login_as_root: login_response,
      login_as_individual: login_response,
      login_as_service: login_response
    )
  end

  let(:login_response) { double(:login_response, token: jwt_token, refresh_token: refresh_token) }
  let(:jwt_token) { "JWT_TOKEN-#{Faker::Alphanumeric.alphanumeric(number: 6)}" }
  let(:refresh_token) { "REFRESH_TOKEN-#{Faker::Alphanumeric.alphanumeric(number: 6)}" }

  let(:endpoint) { Faker::Internet.url }
  let(:password) { Faker::Internet.password }
  let(:email) { Faker::Internet.email }
  let(:database_id) { "DATABASE_ID-#{Faker::Alphanumeric.alphanumeric(number: 6)}" }
  let(:service_name) { "SERVICE_NAME-#{Faker::Alphanumeric.alphanumeric(number: 6)}" }
  let(:frontend_user_id) { "FRONTEND_USER_ID-#{Faker::Alphanumeric.alphanumeric(number: 6)}" }

  describe '#initialize' do
    before do
      allow_any_instance_of(Xminds::Endpoints::Authentication).to receive(:login_as_individual).and_return(login_response)
    end

    context 'when client is initialized by passing arguments' do
      it 'sets the necessary instance variables and attempts to get a root JWT with passed arguments' do
        client = described_class.new(
          type: :individual,
          endpoint: endpoint,
          email: email,
          password: password,
          database_id: database_id,
          service_name: service_name,
          frontend_user_id: frontend_user_id
        )

        expect(client.type).to eq(:individual)
        expect(client.endpoint).to eq(endpoint)
        expect(client.email).to eq(email)
        expect(client.password).to eq(password)
        expect(client.database_id).to eq(database_id)
        expect(client.service_name).to eq(service_name)
        expect(client.frontend_user_id).to eq(frontend_user_id)

        expect(client.jwt_token).to eq(jwt_token)
        expect(client.refresh_token).to eq(refresh_token)
      end
    end

    context 'when client is initialized by Xminds configuration' do
      before do
        Xminds.configure do |config|
          config.endpoint         = endpoint
          config.email            = email
          config.password         = password
          config.database_id      = database_id
          config.service_name     = service_name
          config.frontend_user_id = frontend_user_id
        end
      end

      after { Xminds.reset }

      it 'sets the necessary instance variables and attempts to get a root JWT with Configuration object' do
        client = described_class.new(type: :individual)

        expect(client.type).to eq(:individual)
        expect(client.endpoint).to eq(endpoint)
        expect(client.email).to eq(email)
        expect(client.password).to eq(password)
        expect(client.database_id).to eq(database_id)
        expect(client.service_name).to eq(service_name)
        expect(client.frontend_user_id).to eq(frontend_user_id)

        expect(client.jwt_token).to eq(jwt_token)
        expect(client.refresh_token).to eq(refresh_token)
      end
    end

    context 'when an invalid client type is passed' do
      it 'raises an argument error' do
        expect { described_class.new(type: :INVALID) }.to raise_error(ArgumentError)
      end
    end
  end

  described_class::ENDPOINT_METHODS.each do |endpoint_method, method_names|
    method_names.each do |method_name|
      describe "##{method_name}" do
        before { allow_any_instance_of(Xminds::Client).to receive(:set_jwt_token) }
        it 'has a method defined on the endpoint' do
          expect(described_class.new.send(endpoint_method)).to respond_to(method_name)
        end
      end
    end
  end
end

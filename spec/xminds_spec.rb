# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Xminds do
  let(:default_endpoint) { 'https://api.crossingminds.com/' }
  let(:default_email) { ENV['XMINDS_API_EMAIL'] }
  let(:default_password) { ENV['XMINDS_API_PWD'] }

  let(:endpoint) { Faker::Internet.url }
  let(:email) { Faker::Internet.email }
  let(:password) { Faker::Internet.password }

  let(:set_configuration!) do
    described_class.configure do |config|
      config.endpoint = endpoint
      config.email    = email
      config.password = password
    end
  end

  describe '::configuration' do
    it "returns gems's configuration with default values" do
      expect(described_class.configuration).to be_a(Xminds::Configuration)
      expect(described_class.configuration.endpoint).to eq(default_endpoint)
    end
  end

  describe '::configure' do
    it 'allows setting the global configuration' do
      set_configuration!

      expect(described_class.configuration.endpoint).to eq(endpoint)
      expect(described_class.configuration.email).to eq(email)
      expect(described_class.configuration.password).to eq(password)
    end
  end

  describe '::reset' do
    it 'resets the global configuration back to default' do
      set_configuration!

      described_class.reset

      expect(described_class.configuration.endpoint).to_not eq(endpoint)
      expect(described_class.configuration.email).to_not eq(email)
      expect(described_class.configuration.password).to_not eq(password)

      expect(described_class.configuration.endpoint).to eq(default_endpoint)
      expect(described_class.configuration.email).to eq(default_email)
      expect(described_class.configuration.password).to eq(default_password)
    end
  end
end

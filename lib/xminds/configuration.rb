# frozen_string_literal: true

module Xminds
  # Configuration class used for initializing variables for comminicating
  # with the Crossing Minds API.
  class Configuration
    attr_accessor :endpoint, :email, :password, :database_id, :service_name, :frontend_user_id, :frontend_session_id

    def initialize
      @endpoint         = ENV.fetch('XMINDS_API_ENDPOINT', 'https://api.crossingminds.com/')
      @email            = ENV['XMINDS_API_EMAIL']
      @password         = ENV['XMINDS_API_PWD']
      @database_id      = ENV['XMINDS_API_DATABASE_ID']
      @service_name     = ENV['XMINDS_API_SERVICE_NAME']
      @frontend_user_id = ENV['XMINDS_API_FRONTEND_USER_ID']
      @frontend_session_id = ENV['XMINDS_API_FRONTEND_SESSION_ID']
    end
  end
end

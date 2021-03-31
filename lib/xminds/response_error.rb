# frozen_string_literal: true

module Xminds
  # ResponseError class, raised for any unsuccessful server requests
  class ResponseError < StandardError
    attr_reader :http_status_code, :error_code, :error_name, :error_message, :error_data

    def initialize(http_status_code:, message:)
      @http_status_code = http_status_code
      @error_code       = message[:error_code]
      @error_name       = message[:error_name]
      @error_message    = message[:message]
      @error_data       = message[:error_data]

      super(JSON.generate(message))
    end
  end
end

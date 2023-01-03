# frozen_string_literal: true

module Xminds
  # Request class inherited by all endpoint classes to provide HTTP request functionality
  class Request
    def initialize(endpoint:, jwt_token:)
      @endpoint  = endpoint
      @jwt_token = jwt_token
    end

    private

    def delete(**kwargs)
      request(http_method: Net::HTTP::Delete, **kwargs)
    end

    def get(**kwargs)
      request(http_method: Net::HTTP::Get, **kwargs)
    end

    def patch(**kwargs)
      request(http_method: Net::HTTP::Patch, **kwargs)
    end

    def post(**kwargs)
      request(http_method: Net::HTTP::Post, **kwargs)
    end

    def put(**kwargs)
      request(http_method: Net::HTTP::Put, **kwargs)
    end

    # rubocop:disable Metrics/AbcSize
    def request(http_method:, path: '', query: {}, body: {}, headers: {}, auth_required: true)
      # rubocop:enable Metrics/AbcSize

      url = URI(URI.join(@endpoint, path))

      url.query = URI.encode_www_form(query.compact) if query.compact.any?

      http = Net::HTTP.new(url.host, url.port)

      http.use_ssl = url.scheme == 'https'

      message = http_method.new(url)

      message.body = body.to_json if body.any?

      message['Content-Type']  = 'application/json'
      message['Authorization'] = "Bearer #{@jwt_token}" if auth_required

      headers.each { |header_key, header_value| message[header_key] = header_value }

      response = http.request(message)

      parse(response)
      
    end

    def parse(response)
      case response
      when Net::HTTPNoContent
        Xminds::Response.new
      when Net::HTTPSuccess
        if response['Content-Type']&.include?('application/json')
          ::JSON.parse(response.body, object_class: Xminds::Response)
        else
          Xminds::Response.new(body: response.body)
        end
      else
        message = ::JSON.parse(response.body, symbolize_names: true)

        raise ResponseError.new(http_status_code: response.code.to_i, message: message)
      end
    end
  end
end

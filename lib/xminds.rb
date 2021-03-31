# frozen_string_literal: true

# Ruby standard library
require 'json'
require 'net/http'
require 'ostruct'

# # Xminds core
require 'xminds/client'
require 'xminds/client_error'
require 'xminds/configuration'
require 'xminds/request'
require 'xminds/response'
require 'xminds/response_error'
require 'xminds/version'

require 'xminds/endpoints/authentication'
require 'xminds/endpoints/background_tasks'
require 'xminds/endpoints/database'
require 'xminds/endpoints/items_data_and_properties'
require 'xminds/endpoints/recommendation'
require 'xminds/endpoints/user_ratings'
require 'xminds/endpoints/user_interactions'
require 'xminds/endpoints/users_data_and_properties'

# Xminds is a wrapper module for the xminds Ruby gem
module Xminds
  class << self
    def configuration
      @configuration ||= Xminds::Configuration.new
    end

    def configure
      yield(configuration)
    end

    def reset
      @configuration = Xminds::Configuration.new
    end
  end
end

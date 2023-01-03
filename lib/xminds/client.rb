# frozen_string_literal: true

module Xminds
  # Client class used for communication with the Crossing Minds API.
  class Client
    ENDPOINT_METHODS = {
      authentication: %i[
        list_all_accounts create_individual_account delete_individual_account create_service_account delete_service_account
        login_as_individual login_as_service login_as_root renew_login_with_refresh_token resend_email_verification_code
        verify_email delete_current_account
      ],
      database: %i[create_database list_all_databases current_database delete_current_database current_database_status],
      users_data_and_properties: %i[
        list_all_user_properties create_user_property get_user_property delete_user_property get_user create_or_update_user
        partial_update_user create_or_update_user_bulk partial_update_user_bulk list_all_users list_all_users_by_id
      ],
      items_data_and_properties: %i[
        list_all_item_properties create_item_property get_item_property delete_item_property get_item create_or_update_item
        partial_update_item create_or_update_item_bulk partial_update_item_bulk list_all_items list_all_items_by_id
      ],
      user_ratings: %i[
        create_or_update_rating delete_rating list_all_ratings_for_user create_or_update_ratings_for_user_bulk
        delete_all_ratings_for_user create_or_update_ratings_bulk list_all_ratings
      ],
      user_interactions: %i[create_user_interaction create_user_interactions_bulk],
      recommendation: %i[
        list_similar_item_recommendations list_session_based_item_recommendations list_profile_based_item_recommendations
      ],
      background_tasks: %i[trigger_background_task list_recent_background_tasks]
    }.freeze

    attr_reader :type, :endpoint, :email, :password, :database_id, :frontend_user_id, :frontend_session_id, :service_name, :jwt_token, :refresh_token

    # rubocop:disable Metrics/AbcSize
    def initialize(type: :root, **kwargs)
      # rubocop:enable Metrics/AbcSize
      @type             = type.to_sym
      @endpoint         = kwargs[:endpoint]         || Xminds.configuration.endpoint
      @email            = kwargs[:email]            || Xminds.configuration.email
      @password         = kwargs[:password]         || Xminds.configuration.password
      @database_id      = kwargs[:database_id]      || Xminds.configuration.database_id
      @service_name     = kwargs[:service_name]     || Xminds.configuration.service_name
      @frontend_user_id = kwargs[:frontend_user_id] || Xminds.configuration.frontend_user_id
      @frontend_session_id       = kwargs[:frontend_session_id]       || Xminds.configuration.frontend_session_id

      set_jwt_token
    end

    ENDPOINT_METHODS.each do |endpoint_method, method_names|
      method_names.each do |method_name|
        define_method method_name do |**kwargs|
          if kwargs.empty?
            send(endpoint_method).public_send(method_name)
          else
            send(endpoint_method).public_send(method_name, **kwargs)
          end
        rescue ResponseError => e
          raise e unless e.error_name == 'JwtTokenExpired'

          reset_jwt_token

          retry
        end
      end
    end

    private

    def authentication
      @authentication ||= Endpoints::Authentication.new(
        endpoint: @endpoint,
        jwt_token: @jwt_token
      )
    end

    def database
      @database ||= Endpoints::Database.new(
        endpoint: @endpoint,
        jwt_token: @jwt_token
      )
    end

    def users_data_and_properties
      @users_data_and_properties ||= Endpoints::UsersDataAndProperties.new(
        endpoint: @endpoint,
        jwt_token: @jwt_token
      )
    end

    def items_data_and_properties
      @items_data_and_properties ||= Endpoints::ItemsDataAndProperties.new(
        endpoint: @endpoint,
        jwt_token: @jwt_token
      )
    end

    def user_ratings
      @user_ratings ||= Endpoints::UserRatings.new(
        endpoint: @endpoint,
        jwt_token: @jwt_token
      )
    end

    def user_interactions
      @user_interactions ||= Endpoints::UserInteractions.new(
        endpoint: @endpoint,
        jwt_token: @jwt_token
      )
    end

    def recommendation
      @recommendation ||= Endpoints::Recommendation.new(
        endpoint: @endpoint,
        jwt_token: @jwt_token
      )
    end

    def background_tasks
      @background_tasks ||= Endpoints::BackgroundTasks.new(
        endpoint: @endpoint,
        jwt_token: @jwt_token
      )
    end

    def set_jwt_token
      case @type
      when :root
        set_jwt_as_root
      when :individual
        set_jwt_as_individual
      when :service
        set_jwt_as_service
      else
        raise ArgumentError, "Invalid client type '#{@type}'"
      end
      @authentication = nil
    end

    def set_jwt_as_root
      @jwt_token = authentication.login_as_root(email: @email, password: @password).token
    end

    def set_jwt_as_individual
      authentication.login_as_individual(
        email: @email,
        password: @password,
        database_id: @database_id,
        frontend_user_id: @frontend_user_id,
        frontend_session_id: @frontend_session_id
      ).tap do |response|
        @jwt_token     = response.token
        @refresh_token = response.refresh_token
      end
    end

    def set_jwt_as_service
      authentication.login_as_service(
        service_name: @service_name,
        password: @password,
        database_id: @database_id,
        frontend_user_id: @frontend_user_id,
        frontend_session_id: @frontend_session_id
      ).tap do |response|
        @jwt_token     = response.token
        @refresh_token = response.refresh_token
      end
    end

    def reset_jwt_token
      raise ClientError, 'Refresh token is not set' if @refresh_token.nil?

      authentication.renew_login_with_refresh_token(refresh_token: @refresh_token).tap do |response|
        @jwt_token     = response.token
        @refresh_token = response.refresh_token
      end

      reset_endpoints

      self
    end

    def reset_endpoints
      @authentication            = nil
      @database                  = nil
      @users_data_and_properties = nil
      @items_data_and_properties = nil
      @user_ratings              = nil
      @recommendation            = nil
      @background_tasks          = nil
    end
  end
end

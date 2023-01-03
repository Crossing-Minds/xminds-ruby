# frozen_string_literal: true

module Xminds
  module Endpoints
    # Database class used for authentication related requests with the Crossing Minds API.
    class Authentication < Request
      def list_all_accounts
        get(path: 'organizations/current/accounts/')
      end

      def create_individual_account(email:, password:, role:, first_name:, last_name:)
        post(
          path: 'accounts/individual/',
          body: { password: password, role: role, first_name: first_name, last_name: last_name, email: email }
        )
      end

      def delete_individual_account(email:)
        delete(path: 'accounts/individual/', body: { email: email })
      end

      def create_service_account(service_name:, password:, role:)
        post(
          path: 'accounts/service/',
          body: { name: service_name, password: password, role: role }
        )
      end

      def delete_service_account(service_name:)
        delete(path: 'accounts/service/', body: { name: service_name })
      end

      def login_as_individual(email:, password:, database_id:, frontend_user_id: nil, frontend_session_id: nil)
        post(
          path: 'login/individual/',
          body: {
            email: email,
            password: password,
            db_id: database_id,
            frontend_user_id: frontend_user_id,
            frontend_session_id: frontend_session_id
          }.compact,
          auth_required: false
        )
      end

      def login_as_service(service_name:, password:, database_id:, frontend_user_id: nil, frontend_session_id: nil)
        post(
          path: 'login/service/',
          body: {
            name: service_name,
            password: password,
            db_id: database_id,
            frontend_user_id: frontend_user_id,
            frontend_session_id: frontend_session_id
          }.compact,
          auth_required: false
        )
      end

      def login_as_root(email:, password:)
        post(
          path: 'login/root/',
          body: { email: email, password: password },
          auth_required: false
        )
      end

      def renew_login_with_refresh_token(refresh_token:)
        post(
          path: 'login/refresh-token/',
          body: { refresh_token: refresh_token },
          auth_required: false
        )
      end

      def resend_email_verification_code(email:)
        put(path: 'accounts/resend-verification-code/', body: { email: email })
      end

      def verify_email(email:, code:)
        post(path: 'accounts/verify/', body: { email: email, code: code })
      end

      def delete_current_account
        delete(path: 'accounts/')
      end
    end
  end
end

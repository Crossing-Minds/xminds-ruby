# frozen_string_literal: true

module Xminds
  module Endpoints
    # UsersDataAndProperties class used for users data and properties related requests with the Crossing Minds API.
    class UsersDataAndProperties < Request
      def list_all_user_properties
        get(path: 'users-properties/')
      end

      def create_user_property(property_name:, value_type:, repeated: false)
        post(
          path: 'users-properties/',
          body: {
            property_name: property_name,
            value_type: value_type,
            repeated: repeated
          }
        )
      end

      def get_user_property(property_name:)
        get(path: "users-properties/#{property_name}/")
      end

      def delete_user_property(property_name:)
        delete(path: "users-properties/#{property_name}/")
      end

      def get_user(user_id:)
        get(path: "users/#{user_id}/")
      end

      def create_or_update_user(user_id:, user:)
        put(
          path: "users/#{user_id}/",
          body: { user: user }
        )
      end

      def partial_update_user(user_id:, user:, create_if_missing: false)
        patch(
          path: "users/#{user_id}/",
          body: {
            user: user,
            create_if_missing: create_if_missing
          }
        )
      end

      def create_or_update_user_bulk(users:)
        put(
          path: 'users-bulk/',
          body: { users: users }
        )
      end

      def partial_update_user_bulk(users:, create_if_missing: false)
        patch(
          path: 'users-bulk/',
          body: {
            users: users,
            create_if_missing: create_if_missing
          }
        )
      end

      def list_all_users(amount: nil, cursor: nil)
        get(
          path: 'users-bulk/',
          query: {
            amt: amount,
            cursor: cursor
          }
        )
      end

      def list_all_users_by_id(user_ids:)
        post(
          path: 'users-bulk/list/',
          body: { users_id: user_ids }
        )
      end
    end
  end
end

# frozen_string_literal: true

module Xminds
  module Endpoints
    # Database class used for database related requests with the Crossing Minds API.
    class Database < Request
      def create_database(database_name:, description:, item_id_type:, user_id_type:)
        post(
          path: 'databases/',
          body: {
            name: database_name,
            description: description,
            item_id_type: item_id_type,
            user_id_type: user_id_type
          }
        )
      end

      def list_all_databases(page: nil, amount: nil)
        get(
          path: 'databases/',
          query: {
            page: page,
            amt: amount
          }
        )
      end

      def current_database
        get(path: 'databases/current/')
      end

      def delete_current_database
        delete(path: 'databases/current/')
      end

      def current_database_status
        get(path: 'databases/current/status/')
      end
    end
  end
end

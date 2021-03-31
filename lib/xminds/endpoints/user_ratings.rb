# frozen_string_literal: true

module Xminds
  module Endpoints
    # UserRatings class used for user ratings related requests with the Crossing Minds API.
    class UserRatings < Request
      def create_or_update_rating(user_id:, item_id:, rating:, timestamp: nil)
        put(
          path: "users/#{user_id}/ratings/#{item_id}/",
          body: { rating: rating, timestamp: timestamp }.compact
        )
      end

      def delete_rating(user_id:, item_id:)
        delete(
          path: "users/#{user_id}/ratings/#{item_id}/"
        )
      end

      def list_all_ratings_for_user(user_id:, page: nil, amount: nil)
        get(
          path: "users/#{user_id}/ratings/",
          query: {
            page: page,
            amt: amount
          }
        )
      end

      def create_or_update_ratings_for_user_bulk(user_id:, ratings:)
        put(
          path: "users/#{user_id}/ratings/",
          body: { ratings: ratings }
        )
      end

      def delete_all_ratings_for_user(user_id:)
        delete(path: "users/#{user_id}/ratings/")
      end

      def create_or_update_ratings_bulk(ratings:)
        put(
          path: 'ratings-bulk/',
          body: { ratings: ratings }
        )
      end

      def list_all_ratings(amount: nil, cursor: nil)
        get(
          path: 'ratings-bulk/',
          query: {
            amt: amount,
            cursor: cursor
          }
        )
      end
    end
  end
end

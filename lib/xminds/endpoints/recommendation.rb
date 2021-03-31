# frozen_string_literal: true

module Xminds
  module Endpoints
    # Recommendation class used for recommendation related requests with the Crossing Minds API.
    class Recommendation < Request
      def list_similar_item_recommendations(item_id:, amount: nil, cursor: nil, filters: nil)
        get(
          path: "recommendation/items/#{item_id}/items/",
          query: {
            amt: amount,
            cursor: cursor,
            filters: filters
          }.compact
        )
      end

      # rubocop:disable Layout/LineLength
      def list_session_based_item_recommendations(amount: nil, cursor: nil, filters: nil, ratings: nil, user_properties: nil, exclude_rated_items: false)
        # rubocop:enable Layout/LineLength
        post(
          path: 'recommendation/sessions/items/',
          body: {
            amt: amount,
            cursor: cursor,
            filters: filters,
            ratings: ratings,
            user_properties: user_properties,
            exclude_rated_items: exclude_rated_items
          }.compact
        )
      end

      def list_profile_based_item_recommendations(user_id:, amount: nil, cursor: nil, filters: nil, exclude_rated_items: false)
        get(
          path: "recommendation/users/#{user_id}/items/",
          query: {
            amt: amount,
            cursor: cursor,
            filters: filters,
            exclude_rated_items: exclude_rated_items
          }.compact
        )
      end
    end
  end
end

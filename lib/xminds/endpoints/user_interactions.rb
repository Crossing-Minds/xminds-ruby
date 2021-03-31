# frozen_string_literal: true

module Xminds
  module Endpoints
    # UserInteractions class used for creating a new interaction for a user and an item with the Crossing Minds API.
    class UserInteractions < Request
      def create_user_interaction(user_id:, item_id:, interaction_type:, timestamp: nil)
        post(
          path: "users/#{user_id}/interactions/#{item_id}/",
          body: {
            interaction_type: interaction_type,
            timestamp: timestamp
          }.compact
        )
      end

      def create_user_interactions_bulk(interactions:)
        post(
          path: 'interactions-bulk/',
          body: { interactions: interactions }
        )
      end
    end
  end
end

# frozen_string_literal: true

module Xminds
  module Endpoints
    # ItemsDataAndProperties class used for items data and properties related requests with the Crossing Minds API.
    class ItemsDataAndProperties < Request
      def list_all_item_properties
        get(path: 'items-properties/')
      end

      def create_item_property(property_name:, value_type:, repeated: false)
        post(
          path: 'items-properties/',
          body: {
            property_name: property_name,
            value_type: value_type,
            repeated: repeated
          }
        )
      end

      def get_item_property(property_name:)
        get(path: "items-properties/#{property_name}/")
      end

      def delete_item_property(property_name:)
        delete(path: "items-properties/#{property_name}/")
      end

      def get_item(item_id:)
        get(path: "items/#{item_id}/")
      end

      def create_or_update_item(item_id:, item:)
        put(
          path: "items/#{item_id}/",
          body: { item: item }
        )
      end

      def partial_update_item(item_id:, item:, create_if_missing: false)
        patch(
          path: "items/#{item_id}/",
          body: {
            item: item,
            create_if_missing: create_if_missing
          }
        )
      end

      def create_or_update_item_bulk(items:)
        put(
          path: 'items-bulk/',
          body: { items: items }
        )
      end

      def partial_update_item_bulk(items:, create_if_missing: false)
        patch(
          path: 'items-bulk/',
          body: {
            items: items,
            create_if_missing: create_if_missing
          }
        )
      end

      def list_all_items(amount: nil, cursor: nil)
        get(
          path: 'items-bulk/',
          query: {
            amt: amount,
            cursor: cursor
          }
        )
      end

      def list_all_items_by_id(item_ids:)
        post(
          path: 'items-bulk/list/',
          body: { items_id: item_ids }
        )
      end
    end
  end
end

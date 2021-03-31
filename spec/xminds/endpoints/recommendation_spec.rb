# frozen_string_literal: true

RSpec.describe Xminds::Endpoints::Recommendation do
  before(:all) do
    create_new_test_db
    reset_test_account
    seed_recommendations
    create_new_recommendation_not_ready_test_db

    wait_for_database_to_be_ready!
  end

  after(:all) do
    delete_new_recommendation_not_ready_test_db
  end

  subject { described_class.new(endpoint: endpoint, jwt_token: jwt_token) }

  describe '#list_similar_item_recommendations' do
    context 'on success' do
      let(:item_id) { client.list_all_items.items.sample.item_id }

      it 'returns a list item IDs similar to the item ID supplied' do
        expect(client.current_database_status.status).to eq('ready')

        resp = subject.list_similar_item_recommendations(
          item_id: item_id,
          filters: ['genre:notempty'],
          amount: 5
        )

        expect(resp).to be_a(Xminds::Response)
        expect(resp.items_id).to be_a(Array)
        expect(resp.items_id.count).to be(5)
      end
    end

    context 'when the machine learning has not yet been trained for the database' do
      let(:item_id) { Faker::Internet.uuid }

      before(:each) do
        recommendation_not_ready_client.create_or_update_item(item_id: item_id, item: { item_property: 5 })
      end

      subject { described_class.new(endpoint: endpoint, jwt_token: recommendation_not_ready_client.jwt_token) }

      it 'raises a DATABASE_NOT_READY error' do
        expect do
          subject.list_similar_item_recommendations(item_id: item_id)
        end.to raise_error(
          an_instance_of(Xminds::ResponseError).and having_attributes(
            error_name: 'ServerUnavailable',
            error_data: {
              error: 'The database is not ready. Wait using /status/',
              name: 'DATABASE_NOT_READY'
            }
          )
        )
      end
    end

    context 'when the item does not exist' do
      xit 'raises a ITEM_NOT_FOUND error' do
        # TODO: skipping, API response does not return an error response when the item cannot be found
        # instead items_id points to an empty array
      end
    end

    context 'when a filter is invalid' do
      let(:item_id) { client.list_all_items.items.sample.item_id }

      it 'raises a WRONG_DATA_TYPE error' do
        expect do
          subject.list_similar_item_recommendations(
            item_id: item_id,
            amount: 5,
            filters: ['INVALID:notempty']
          )
        end.to raise_error(
          an_instance_of(Xminds::ResponseError).and having_attributes(
            error_name: 'WrongData',
            error_data: {
              error: "unknown property 'INVALID' in filters"
            }
          )
        )
      end
    end
  end

  describe '#list_session_based_item_recommendations' do
    context 'on success' do
      it 'returns a list of session based item IDs' do
        resp = subject.list_session_based_item_recommendations(
          amount: 8,
          filters: [{ property_name: 'genre', op: 'notempty' }],
          exclude_rated_items: false
        )

        expect(resp).to be_a(Xminds::Response)
        expect(resp.items_id).to be_a(Array)
        expect(resp.items_id.count).to be(8)
      end
    end

    context 'when the machine learning has not yet been trained for the database' do
      subject { described_class.new(endpoint: endpoint, jwt_token: recommendation_not_ready_client.jwt_token) }

      it 'raises a DATABASE_NOT_READY error' do
        expect do
          subject.list_session_based_item_recommendations(
            amount: 8,
            filters: [{ property_name: 'item_property', op: 'lt', value: 2 }],
            exclude_rated_items: false
          )
        end.to raise_error(
          an_instance_of(Xminds::ResponseError).and having_attributes(
            error_name: 'ServerUnavailable',
            error_data: {
              error: 'The database is not ready. Wait using /status/',
              name: 'DATABASE_NOT_READY'
            }
          )
        )
      end
    end

    context 'when a filter is invalid' do
      it 'raises a WRONG_DATA_TYPE error' do
        expect do
          subject.list_session_based_item_recommendations(
            filters: [{ property_name: 'INVALID', op: 'gt', value: 4.0 }]
          )
        end.to raise_error(
          an_instance_of(Xminds::ResponseError).and having_attributes(
            error_name: 'WrongData',
            error_data: { error: "unknown property 'INVALID' in filters" }
          )
        )
      end
    end
  end

  describe '#list_profile_based_item_recommendations' do
    context 'on success' do
      let(:user_id) { client.list_all_users.users.sample.user_id }

      it 'returns a list of user profile based item IDs' do
        resp = subject.list_profile_based_item_recommendations(
          user_id: user_id,
          amount: 5,
          filters: ['genre:notempty'],
          exclude_rated_items: false
        )

        expect(resp).to be_a(Xminds::Response)
        expect(resp.items_id).to be_a(Array)
        expect(resp.items_id.count).to be(5)
      end
    end

    context 'when the machine learning has not yet been trained for the database' do
      let(:user_id) { Faker::Internet.uuid }

      before(:each) do
        recommendation_not_ready_client.create_or_update_user(user_id: user_id, user: { user_property: 5 })
      end

      subject { described_class.new(endpoint: endpoint, jwt_token: recommendation_not_ready_client.jwt_token) }

      it 'raises a DATABASE_NOT_READY error' do
        expect do
          subject.list_profile_based_item_recommendations(
            user_id: user_id,
            filters: ['item_property:notempty'],
            exclude_rated_items: false
          )
        end.to raise_error(
          an_instance_of(Xminds::ResponseError).and having_attributes(
            error_name: 'ServerUnavailable',
            error_data: {
              error: 'The database is not ready. Wait using /status/',
              name: 'DATABASE_NOT_READY'
            }
          )
        )
      end
    end

    context 'when the user does not exist' do
      xit 'raises a USER_NOT_FOUND error' do
        # TODO: skipping, API response does not return an error response when the item cannot be found
        # instead items_id points to an array of actual item IDs when the user ID is invalid
      end
    end

    context 'when a filter is invalid' do
      let(:user_id) { client.list_all_users.users.sample.user_id }

      it 'raises a WRONG_DATA_TYPE error' do
        expect do
          subject.list_profile_based_item_recommendations(
            user_id: user_id,
            amount: 5,
            filters: ['INVALID:notempty'],
            exclude_rated_items: false
          )
        end.to raise_error(
          an_instance_of(Xminds::ResponseError).and having_attributes(
            error_name: 'WrongData',
            error_data: { error: "unknown property 'INVALID' in filters" }
          )
        )
      end
    end
  end
end

# frozen_string_literal: true

RSpec.describe Xminds::Endpoints::UserInteractions do
  before(:all) do
    create_new_test_db
    reset_test_account

    @item_id             = Faker::Internet.uuid
    @user_id             = Faker::Internet.uuid
    @item_property_name  = 'test_item_property'
    @user_property_name  = 'test_user_property'
    @item_property_value = 'unicode'
    @user_property_value = 'unicode'

    create_item_property(@item_property_name, @item_property_value)
    create_user_property(@user_property_name, @user_property_value)

    create_or_update_item(@item_id, @item_property_name => @item_property_value)
    create_or_update_user(@user_id, @user_property_name => @user_property_value)
  end

  let(:item_id) { @item_id }
  let(:user_id) { @user_id }

  subject { described_class.new(endpoint: endpoint, jwt_token: jwt_token) }

  describe '#create_user_interaction' do
    context 'on success' do

      # TODO: need usable interaction_type to get successful response
      xit 'creates the new interaction' do
        resp = client.create_user_interaction(user_id: user_id, item_id: item_id, interaction_type: 'interaction_type')
      end
    end

    context 'no "implicit-to-explicit" parameters have been set ' do
      it 'returns a DB_IMPLICIT_TO_EXPLICIT_PARAMS_NOT_FOUND error' do
        expect do
          client.create_user_interaction(user_id: user_id, item_id: item_id, interaction_type: 'interaction_type')
        end.to raise_error(
          an_instance_of(Xminds::ResponseError).and having_attributes(
            error_name: 'ServerUnavailable',
            error_data: {
              error: 'The database is not ready for automatic implicit-to-explicit conversion',
              name: 'DB_IMPLICIT_TO_EXPLICIT_PARAMS_NOT_FOUND'
            }
          )
        )
      end
    end
  end

  describe '#create_user_interactions_bulk' do
    context 'on success' do
      # TODO: need usable interaction_type to get successful response
      xit 'creates the new interactions' do
        resp = client.create_user_interactions_bulk(
          interactions: [
            { user_id: user_id, item_id: item_id, interaction_type: 'interaction_type', timestamp: Time.now.to_i }
          ]
        )
      end
    end

    context 'no "implicit-to-explicit" parameters have been set ' do
      it 'returns a DB_IMPLICIT_TO_EXPLICIT_PARAMS_NOT_FOUND error' do
        interactions = [{ user_id: user_id, item_id: item_id, interaction_type: 'interaction_type', timestamp: Time.now.to_i }]

        expect do
          client.create_user_interactions_bulk(interactions: interactions)
        end.to raise_error(
          an_instance_of(Xminds::ResponseError).and having_attributes(
            error_name: 'ServerUnavailable',
            error_data: {
              error: 'The database is not ready for automatic implicit-to-explicit conversion',
              name: 'DB_IMPLICIT_TO_EXPLICIT_PARAMS_NOT_FOUND'
            }
          )
        )
      end
    end
  end
end

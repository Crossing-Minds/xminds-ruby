# frozen_string_literal: true

RSpec.describe Xminds::Endpoints::UserRatings do
  before(:all) do
    create_new_test_db
    reset_test_account

    @test_user_property = 'test_user_property'
    @test_item_property = 'test_item_property'
    @user_id            = Faker::Internet.uuid
    @item_id            = Faker::Internet.uuid

    create_user_property(@test_user_property, 'int8')
    create_item_property(@test_item_property, 'int8')
    create_or_update_user(@user_id, test_user_property: Faker::Number.within(range: 1..100))
    create_or_update_item(@item_id, test_item_property: Faker::Number.within(range: 1..100))
  end

  let(:user_id) { @user_id }
  let(:item_id) { @item_id }
  let(:test_user_property) { @test_user_property }
  let(:test_item_property) { @test_item_property }

  subject { described_class.new(endpoint: endpoint, jwt_token: jwt_token) }

  describe '#create_or_update_rating' do
    context 'on success' do
      after(:each) { client.delete_rating(user_id: user_id, item_id: item_id) }

      it 'creates or updates a rating' do
        rating = Faker::Number.within(range: 1.0..5.0).round(1)
        resp   = subject.create_or_update_rating(user_id: user_id, item_id: item_id, rating: rating)

        expect(resp).to be_a(Xminds::Response)
        expect(resp.body).to be_a(String)
      end
    end
  end

  describe '#delete_rating' do
    context 'on success' do
      before(:each) { client.create_or_update_rating(user_id: user_id, item_id: item_id, rating: 5.0) }
      after(:each) { client.delete_all_ratings_for_user(user_id: user_id) }

      it 'deletes the rating' do
        resp = subject.delete_rating(user_id: user_id, item_id: item_id)

        expect(resp).to be_a(Xminds::Response)
        expect(resp.body).to be_a(String)
      end
    end

    context 'when the rating does not exist' do
      let(:item_id) { Faker::Internet.uuid }

      it 'rases a NotFoundError' do
        expect do
          subject.delete_rating(user_id: user_id, item_id: item_id)
        end.to raise_error(
          an_instance_of(Xminds::ResponseError).and having_attributes(
            error_name: 'NotFoundError',
            error_data: {
              type: 'rating',
              key: "user:b'#{user_id}' item:b'#{item_id}'",
              name: 'USER_RATING_NOT_FOUND'
            }
          )
        )
      end
    end
  end

  describe '#list_all_ratings_for_user' do
    context 'on success' do
      before(:each) { client.create_or_update_rating(user_id: user_id, item_id: item_id, rating: 5.0) }
      after(:each) { client.delete_all_ratings_for_user(user_id: user_id) }

      it 'returns all the ratings for the user' do
        resp = subject.list_all_ratings_for_user(user_id: user_id, page: 1, amount: 1)

        expect(resp).to be_a(Xminds::Response)
        expect(resp.user_ratings).to be_a(Array)
        expect(resp.user_ratings.count).to be(1)
        expect(resp.user_ratings.first.rating).to eq(5.0)
      end
    end
  end

  describe '#create_or_update_ratings_for_user_bulk' do
    context 'on success' do
      let(:item_id1) { Faker::Internet.uuid }
      let(:item_id2) { Faker::Internet.uuid }

      before(:each) do
        create_or_update_item(item_id1, test_item_property: Faker::Number.within(range: 1..100))
        create_or_update_item(item_id2, test_item_property: Faker::Number.within(range: 1..100))
      end

      it 'creates or updates the ratings' do
        resp = subject.create_or_update_ratings_for_user_bulk(
          user_id: user_id,
          ratings: [
            {
              item_id: item_id1,
              rating: 2.5,
              timestamp: 1_607_997_600
            }, {
              item_id: item_id2,
              rating: 3.4,
              timestamp: 1_607_997_600
            }
          ]
        )

        expect(resp).to be_a(Xminds::Response)
        expect(resp.body).to be_a(String)
      end
    end
  end

  describe '#delete_all_ratings_for_user' do
    context 'on success' do
      it 'deletes all of the ratings for a user' do
        resp = subject.delete_all_ratings_for_user(user_id: user_id)

        expect(resp).to be_a(Xminds::Response)
        expect(resp.body).to be_a(String)
      end
    end
  end

  describe '#create_or_update_ratings_bulk' do
    context 'on success' do
      let(:item_id1) { Faker::Internet.uuid }
      let(:item_id2) { Faker::Internet.uuid }
      let(:user_id1) { Faker::Internet.uuid }
      let(:user_id2) { Faker::Internet.uuid }

      before(:each) do
        create_or_update_item(item_id1, test_item_property: Faker::Number.within(range: 1..100))
        create_or_update_item(item_id2, test_item_property: Faker::Number.within(range: 1..100))
        create_or_update_user(user_id1, test_user_property: Faker::Number.within(range: 1..100))
        create_or_update_user(user_id2, test_user_property: Faker::Number.within(range: 1..100))
      end

      it 'creates or updates the ratings' do
        resp = subject.create_or_update_ratings_bulk(
          ratings: [
            {
              user_id: user_id1,
              item_id: item_id1,
              rating: 2.2,
              timestamp: 1_607_997_800
            },{
              user_id: user_id1,
              item_id: item_id2,
              rating: 3.3,
              timestamp: 1_607_997_800
            },{
              user_id: user_id2,
              item_id: item_id1,
              rating: 4.4,
              timestamp: 1_607_997_800
            },{
              user_id: user_id2,
              item_id: item_id2,
              rating: 1.1,
              timestamp: 1_607_997_800
            }
          ]
        )

        expect(resp).to be_a(Xminds::Response)
        expect(resp.body).to be_a(String)
      end
    end
  end

  describe '#list_all_ratings' do
    context 'on success' do
      before(:each) do
        client.delete_all_ratings_for_user(user_id: user_id)
        client.create_or_update_rating(user_id: user_id, item_id: item_id, rating: 5.0)
      end

      it 'returns all the ratings' do
        resp = subject.list_all_ratings(amount: 1)

        expect(resp).to be_a(Xminds::Response)
        expect(resp.ratings).to be_a(Array)
        expect(resp.ratings.count).to be(1)
      end
    end
  end
end

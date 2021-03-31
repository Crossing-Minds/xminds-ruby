# frozen_string_literal: true

RSpec.describe Xminds::Endpoints::UsersDataAndProperties do
  before(:all) do
    create_new_test_db
    reset_test_account

    @property_name = 'age'
    @value_type    = 'int8'

    create_user_property(@property_name, @value_type)
  end

  let(:property_name) { @property_name }
  let(:value_type) { @value_type }
  let(:property_value) { Faker::Number.within(range: 1..100) }

  subject { described_class.new(endpoint: endpoint, jwt_token: jwt_token) }

  describe '#list_all_user_properties' do
    context 'on success' do
      it 'returns all the user properties' do
        resp = subject.list_all_user_properties

        expect(resp).to be_a(Xminds::Response)
        expect(resp.properties).to be_a(Array)
      end
    end
  end

  describe '#create_user_property' do
    let(:property_name) { 'test_property_name' }

    before(:each) { delete_user_property(property_name) }
    after(:each) { delete_user_property(property_name) }

    context 'on success' do
      it 'creates a new user property' do
        resp = subject.create_user_property(property_name: property_name, value_type: value_type)

        expect(resp).to be_a(Xminds::Response)
        expect(resp.body).to be_a(String)
      end
    end

    context 'when the user property already exists' do
      it 'raises a DuplicatedError' do
        subject.create_user_property(property_name: property_name, value_type: value_type)

        expect do
          subject.create_user_property(property_name: property_name, value_type: value_type)
        end.to raise_error(
          an_instance_of(Xminds::ResponseError).and having_attributes(
            error_name: 'DuplicatedError',
            error_data: {
              type: 'user-property',
              key: property_name,
              name: 'DUPLICATED_USER_PROPERTY'
            }
          )
        )
      end
    end

    context 'when the user value type is invalid' do
      it 'raises a WrongData' do
        expect do
          subject.create_user_property(property_name: 'age', value_type: 'INVALID')
        end.to raise_error(
          an_instance_of(Xminds::ResponseError).and having_attributes(
            error_name: 'WrongData',
            error_data: {
              query: {
                value_type: ['INVALID is not valid. Please refer to the "Property Types" documentation']
              }
            }
          )
        )
      end
    end
  end

  describe '#get_user_property' do
    context 'on success' do
      it 'returns the user property' do
        resp = subject.get_user_property(property_name: property_name)

        expect(resp).to be_a(Xminds::Response)
        expect(resp.property_name).to eq(property_name)
        expect(resp.value_type).to eq(value_type)
        expect(resp.repeated).to be(false)
      end
    end

    context 'when the user property cannot be found' do
      it 'rases a NotFoundError' do
        expect do
          subject.get_user_property(property_name: 'invalid_user_property')
        end.to raise_error(
          an_instance_of(Xminds::ResponseError).and having_attributes(
            error_name: 'NotFoundError',
            error_data: {
              type: 'user-property',
              key: 'invalid_user_property',
              name: 'USER_PROPERTY_NOT_FOUND'
            }
          )
        )
      end
    end
  end

  describe '#delete_user_property' do
    context 'on success' do
      after(:each) { create_user_property(property_name, value_type) }

      it 'it deletes the user property' do
        resp = subject.delete_user_property(property_name: property_name)

        expect(resp).to be_a(Xminds::Response)
        expect(resp.body).to be_a(String)
      end
    end

    context 'when the user property cannot be found' do
      it 'rases a NotFoundError' do
        expect do
          subject.delete_user_property(property_name: 'invalid_user_property')
        end.to raise_error(
          an_instance_of(Xminds::ResponseError).and having_attributes(
            error_name: 'NotFoundError',
            error_data: {
              type: 'user-property',
              key: 'invalid_user_property',
              name: 'USER_PROPERTY_NOT_FOUND'
            }
          )
        )
      end
    end
  end

  describe '#get_user' do
    context 'on success' do
      let(:user_id) { Faker::Internet.uuid }

      before(:each) { create_or_update_user(user_id, property_name => property_value) }

      it 'returns the found user' do
        resp = subject.get_user(user_id: user_id)

        expect(resp).to be_a(Xminds::Response)
        expect(resp.user.age).to be(property_value)
      end
    end

    context 'when the user cannot be found' do
      let(:user_id) { Faker::Internet.uuid }

      it 'raises a NotFoundError' do
        expect do
          subject.get_user(user_id: user_id)
        end.to raise_error(
          an_instance_of(Xminds::ResponseError).and having_attributes(
            error_name: 'NotFoundError',
            error_data: {
              type: 'user',
              key: user_id,
              name: 'USER_NOT_FOUND'
            }
          )
        )
      end
    end
  end

  describe '#create_or_update_user' do
    let(:user_id) { Faker::Internet.uuid }

    context 'on success' do
      it 'it creates or updates the user' do
        resp = subject.create_or_update_user(
          user_id: user_id,
          user: { property_name => property_value }
        )

        expect(resp).to be_a(Xminds::Response)
        expect(resp.body).to be_a(String)
      end
    end

    context 'attempting to set an invalid property' do
      it 'raises a WrongData' do
        expect do
          subject.create_or_update_user(
            user_id: user_id,
            user: { invalid: 'INVALID' }
          )
        end.to raise_error(
          an_instance_of(Xminds::ResponseError).and having_attributes(
            error_name: 'WrongData',
            error_data: {
              error: 'unknown property "invalid" with "repeated=False". Available: [\'age\']',
              name: 'WRONG_DATA_TYPE'
            }
          )
        )
      end
    end
  end

  describe '#partial_update_user' do
    context 'on success' do
      let(:user_id) { Faker::Internet.uuid }

      before(:each) { create_or_update_user(user_id, property_name => property_value) }

      it 'updates the user' do
        new_property_value = Faker::Number.within(range: 1..100)

        resp = subject.partial_update_user(
          user_id: user_id,
          user: { property_name => new_property_value }
        )

        expect(resp).to be_a(Xminds::Response)
        expect(resp.body).to eq('')
      end

      context 'when an invalid property is sent' do
        it 'raises a WrongData error' do
          expect do
            subject.partial_update_user(
              user_id: user_id,
              user: { invalid: 'INVALID' }
            )
          end.to raise_error(
            an_instance_of(Xminds::ResponseError).and having_attributes(
              error_name: 'WrongData',
              error_data: {
                error: 'unknown property "invalid" with "repeated=False". Available: [\'age\']',
                name: 'WRONG_DATA_TYPE'
              }
            )
          )
        end
      end

      context 'when an user cannot be found' do
        it 'raises a NotFoundError' do
          expect do
            subject.partial_update_user(
              user_id: Faker::Internet.uuid,
              user: { property_name => property_value }
            )
          end.to raise_error(
            an_instance_of(Xminds::ResponseError).and having_attributes(
              error_name: 'NotFoundError',
              error_data: {
                type: 'user',
                key: nil,
                name: 'USER_NOT_FOUND'
              }
            )
          )
        end
      end
    end
  end

  describe '#create_or_update_user_bulk' do
    context 'on success' do
      let(:user_id1) { Faker::Internet.uuid }
      let(:user_id2) { Faker::Internet.uuid }
      let(:user_age1) { Faker::Number.within(range: 1..100) }
      let(:user_age2) { Faker::Number.within(range: 1..100) }

      it 'creates or updates the users' do
        resp = subject.create_or_update_user_bulk(
          users: [
            {
              user_id: user_id1,
              age: user_age1
            }, {
              user_id: user_id2,
              age: user_age2
            }
          ]
        )

        expect(resp).to be_a(Xminds::Response)
        expect(resp.body).to be_a(String)
      end
    end

    context 'attempting to set an invalid property' do
      let(:user_id) { Faker::Internet.uuid }

      it 'raises a WrongData' do
        expect do
          subject.create_or_update_user_bulk(
            users: [
              {
                user_id: user_id,
                invalid: 'INVALID'
              }
            ]
          )
        end.to raise_error(
          an_instance_of(Xminds::ResponseError).and having_attributes(
            error_name: 'WrongData',
            error_data: {
              error: 'unknown property "invalid" with "repeated=False". Available: [\'age\']',
              name: 'WRONG_DATA_TYPE'
            }
          )
        )
      end
    end

    context 'when two users with the same user_id are attempting to be updated' do
      let(:user_id) { Faker::Internet.uuid }
      let(:property_value1) { Faker::Number.within(range: 1..100) }
      let(:property_value2) { property_value1 + 5 }

      it 'raises a WrongData' do
        expect do
          subject.create_or_update_user_bulk(
            users: [
              {
                user_id: user_id,
                property_name => property_value1
              }, {
                user_id: user_id,
                property_name => property_value2
              }
            ]
          )
        end.to raise_error(
          an_instance_of(Xminds::ResponseError).and having_attributes(
            error_name: 'DuplicatedError',
            error_data: {
              type: 'user',
              key: nil,
              name: 'DUPLICATED_USER_ID'
            }
          )
        )
      end
    end
  end

  describe '#partial_update_user_bulk' do
    context 'on success' do
      let(:user_id1) { Faker::Internet.uuid }
      let(:user_id2) { Faker::Internet.uuid }
      let(:user_prop1) { Faker::Number.within(range: 1..100) }
      let(:user_prop2) { Faker::Number.within(range: 1..100) }

      it 'creates or updates the users' do
        resp = subject.partial_update_user_bulk(
          users: [
            {
              user_id: user_id1,
              property_name => user_prop1
            }, {
              user_id: user_id2,
              property_name => user_prop2
            }
          ],
          create_if_missing: true
        )

        expect(resp).to be_a(Xminds::Response)
        expect(resp.body).to be_a(String)
      end
    end

    context 'attempting to set an invalid property' do
      let(:user_id) { Faker::Internet.uuid }

      it 'raises a WrongData' do
        expect do
          subject.partial_update_user_bulk(
            users: [
              {
                user_id: user_id,
                invalid: 'INVALID'
              }
            ],
            create_if_missing: true
          )
        end.to raise_error(
          an_instance_of(Xminds::ResponseError).and having_attributes(
            error_name: 'WrongData',
            error_data: {
              error: 'unknown property "invalid" with "repeated=False". Available: [\'age\']',
              name: 'WRONG_DATA_TYPE'
            }
          )
        )
      end
    end

    context 'when two users with the same user_id are attempting to be updated' do
      let(:user_id) { Faker::Internet.uuid }
      let(:property_value1) { Faker::Number.within(range: 1..100) }
      let(:property_value2) { property_value1 + 5 }

      it 'raises a DuplicatedError' do
        expect do
          subject.partial_update_user_bulk(
            users: [
              {
                user_id: user_id,
                property_name => property_value1
              }, {
                user_id: user_id,
                property_name => property_value2
              }
            ],
            create_if_missing: true
          )
        end.to raise_error(
          an_instance_of(Xminds::ResponseError).and having_attributes(
            error_name: 'DuplicatedError',
            error_data: {
              type: 'user',
              key: nil,
              name: 'DUPLICATED_USER_ID'
            }
          )
        )
      end
    end
  end

  describe '#list_all_users' do
    context 'on success' do
      it 'returns the users' do
        resp = subject.list_all_users(amount: 1)

        expect(resp).to be_a(Xminds::Response)
        expect(resp.users).to be_a(Array)
      end
    end
  end

  describe '#list_all_users_by_id' do
    let(:user_ids) { Array.new(3) { Faker::Internet.uuid } }

    before(:each) { user_ids.each { |user_id| create_or_update_user(user_id) } }

    context 'on success' do
      it 'returns the users' do
        resp = subject.list_all_users_by_id(user_ids: user_ids)

        expect(resp).to be_a(Xminds::Response)
        expect(resp.users.count).to be(user_ids.count)
      end
    end
  end
end

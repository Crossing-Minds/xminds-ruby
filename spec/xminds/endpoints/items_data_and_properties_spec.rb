# frozen_string_literal: true

RSpec.describe Xminds::Endpoints::ItemsDataAndProperties do
  before(:all) do
    create_new_test_db
    reset_test_account

    @property_name = 'test_item_property'
    @value_type    = 'int8'

    create_item_property(@property_name, @value_type)
  end

  let(:property_name) { @property_name }
  let(:value_type) { @value_type }
  let(:property_value) { Faker::Number.within(range: 1..100) }

  subject { described_class.new(endpoint: endpoint, jwt_token: jwt_token) }

  describe '#list_all_item_properties' do
    context 'on success' do
      it 'returns all the item properties' do
        resp = subject.list_all_item_properties

        expect(resp).to be_a(Xminds::Response)
        expect(resp.properties).to be_a(Array)
      end
    end
  end

  describe '#create_item_property' do
    let(:property_name) { 'test_create_item_property' }

    before(:each) { delete_item_property(property_name) }
    after(:each) { delete_item_property(property_name) }

    context 'on success' do
      it 'creates a new item property' do
        resp = subject.create_item_property(property_name: property_name, value_type: value_type)

        expect(resp).to be_a(Xminds::Response)
        expect(resp.body).to be_a(String)
      end
    end

    context 'when the item property already exists' do
      it 'raises a DuplicatedError' do
        subject.create_item_property(property_name: property_name, value_type: value_type)

        expect do
          subject.create_item_property(property_name: property_name, value_type: value_type)
        end.to raise_error(
          an_instance_of(Xminds::ResponseError).and having_attributes(
            error_name: 'DuplicatedError',
            error_data: {
              type: 'item-property',
              key: property_name,
              name: 'DUPLICATED_ITEM_PROPERTY'
            }
          )
        )
      end
    end

    context 'when the item value type is invalid' do
      it 'raises a WrongData' do
        expect do
          subject.create_item_property(property_name: property_name, value_type: 'INVALID')
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

  describe '#get_item_property' do
    context 'on success' do
      it 'returns the item property' do
        resp = subject.get_item_property(property_name: property_name)

        expect(resp).to be_a(Xminds::Response)
        expect(resp.property_name).to eq(property_name)
        expect(resp.value_type).to eq(value_type)
        expect(resp.repeated).to be(false)
      end
    end

    context 'when the item property cannot be found' do
      it 'rases a NotFoundError' do
        expect do
          subject.get_item_property(property_name: 'invalid_item_property')
        end.to raise_error(
          an_instance_of(Xminds::ResponseError).and having_attributes(
            error_name: 'NotFoundError',
            error_data: {
              type: 'item-property',
              key: 'invalid_item_property',
              name: 'ITEM_PROPERTY_NOT_FOUND'
            }
          )
        )
      end
    end
  end

  describe '#delete_item_property' do
    context 'on success' do
      after(:each) { create_item_property(property_name, value_type) }

      it 'it deletes the item property' do
        resp = subject.delete_item_property(property_name: 'test_item_property')

        expect(resp).to be_a(Xminds::Response)
        expect(resp.body).to be_a(String)
      end
    end

    context 'when the item property cannot be found' do
      it 'rases a NotFoundError' do
        expect do
          subject.delete_item_property(property_name: 'invalid_item_property')
        end.to raise_error(
          an_instance_of(Xminds::ResponseError).and having_attributes(
            error_name: 'NotFoundError',
            error_data: {
              type: 'item-property',
              key: 'invalid_item_property',
              name: 'ITEM_PROPERTY_NOT_FOUND'
            }
          )
        )
      end
    end
  end

  describe '#get_item' do
    context 'on success' do
      let(:item_id) { Faker::Internet.uuid }

      before(:each) { create_or_update_item(item_id, property_name => property_value) }

      it 'returns the found item' do
        resp = subject.get_item(item_id: item_id)

        expect(resp).to be_a(Xminds::Response)
        expect(resp.item.test_item_property).to be(property_value)
      end
    end

    context 'when the item cannot be found' do
      let(:item_id) { Faker::Internet.uuid }

      it 'raises a NotFoundError' do
        expect do
          subject.get_item(item_id: item_id)
        end.to raise_error(
          an_instance_of(Xminds::ResponseError).and having_attributes(
            error_name: 'NotFoundError',
            error_data: {
              type: 'item',
              key: item_id,
              name: 'ITEM_NOT_FOUND'
            }
          )
        )
      end
    end
  end

  describe '#create_or_update_item' do
    let(:item_id) { Faker::Internet.uuid }

    context 'on success' do
      it 'it creates or updates the item' do
        resp = subject.create_or_update_item(
          item_id: item_id,
          item: { property_name => property_value }
        )

        expect(resp).to be_a(Xminds::Response)
        expect(resp.body).to be_a(String)
      end
    end

    context 'attempting to set an invalid property' do
      it 'raises a WrongData' do
        expect do
          subject.create_or_update_item(
            item_id: item_id,
            item: { invalid: 'INVALID' }
          )
        end.to raise_error(
          an_instance_of(Xminds::ResponseError).and having_attributes(
            error_name: 'WrongData',
            error_data: {
              error: 'unknown property "invalid" with "repeated=False". Available: [\'test_item_property\']',
              name: 'WRONG_DATA_TYPE'
            }
          )
        )
      end
    end
  end

  describe '#partial_update_item' do
    context 'on success' do
      let(:item_id) { Faker::Internet.uuid }

      before(:each) { create_or_update_item(item_id, property_name => property_value) }

      it 'updates the item' do
        new_property_value = Faker::Number.within(range: 1..100)

        resp = subject.partial_update_item(
          item_id: item_id,
          item: { property_name => new_property_value }
        )

        expect(resp).to be_a(Xminds::Response)
        expect(resp.body).to eq('')
      end

      context 'when an invalid property is sent' do
        it 'raises a WrongData error' do
          expect do
            subject.partial_update_item(
              item_id: item_id,
              item: { invalid: 'INVALID' }
            )
          end.to raise_error(
            an_instance_of(Xminds::ResponseError).and having_attributes(
              error_name: 'WrongData',
              error_data: {
                error: 'unknown property "invalid" with "repeated=False". Available: [\'test_item_property\']',
                name: 'WRONG_DATA_TYPE'
              }
            )
          )
        end
      end

      context 'when an item cannot be found' do
        it 'raises a NotFoundError' do
          expect do
            subject.partial_update_item(
              item_id: Faker::Internet.uuid,
              item: { property_name => property_value }
            )
          end.to raise_error(
            an_instance_of(Xminds::ResponseError).and having_attributes(
              error_name: 'NotFoundError',
              error_data: {
                type: 'item',
                key: nil,
                name: 'ITEM_NOT_FOUND'
              }
            )
          )
        end
      end
    end
  end

  describe '#create_or_update_item_bulk' do
    context 'on success' do
      let(:item_id1) { Faker::Internet.uuid }
      let(:item_id2) { Faker::Internet.uuid }
      let(:item_prop1) { Faker::Number.within(range: 1..100) }
      let(:item_prop2) { Faker::Number.within(range: 1..100) }

      it 'creates or updates the items' do
        resp = subject.create_or_update_item_bulk(
          items: [
            {
              item_id: item_id1,
              test_item_property: item_prop1
            }, {
              item_id: item_id2,
              test_item_property: item_prop2
            }
          ]
        )

        expect(resp).to be_a(Xminds::Response)
        expect(resp.body).to be_a(String)
      end
    end

    context 'attempting to set an invalid property' do
      let(:item_id) { Faker::Internet.uuid }

      it 'raises a WrongData' do
        expect do
          subject.create_or_update_item_bulk(
            items: [
              {
                item_id: item_id,
                invalid: 'INVALID'
              }
            ]
          )
        end.to raise_error(
          an_instance_of(Xminds::ResponseError).and having_attributes(
            error_name: 'WrongData',
            error_data: {
              error: 'unknown property "invalid" with "repeated=False". Available: [\'test_item_property\']',
              name: 'WRONG_DATA_TYPE'
            }
          )
        )
      end
    end

    context 'when two items with the same item_id are attempting to be updated' do
      let(:item_id) { Faker::Internet.uuid }
      let(:property_value1) { Faker::Number.within(range: 1..100) }
      let(:property_value2) { property_value1 + 5 }

      it 'raises a WrongData' do
        expect do
          subject.create_or_update_item_bulk(
            items: [
              {
                item_id: item_id,
                property_name => property_value1
              }, {
                item_id: item_id,
                property_name => property_value2
              }
            ]
          )
        end.to raise_error(
          an_instance_of(Xminds::ResponseError).and having_attributes(
            error_name: 'DuplicatedError',
            error_data: {
              type: 'item',
              key: nil,
              name: 'DUPLICATED_ITEM_ID'
            }
          )
        )
      end
    end
  end

  describe '#partial_update_item_bulk' do
    context 'on success' do
      let(:item_id1) { Faker::Internet.uuid }
      let(:item_id2) { Faker::Internet.uuid }
      let(:item_prop1) { Faker::Number.within(range: 1..100) }
      let(:item_prop2) { Faker::Number.within(range: 1..100) }

      it 'creates or updates the items' do
        resp = subject.partial_update_item_bulk(
          items: [
            {
              item_id: item_id1,
              test_item_property: item_prop1
            }, {
              item_id: item_id2,
              test_item_property: item_prop2
            }
          ],
          create_if_missing: true
        )

        expect(resp).to be_a(Xminds::Response)
        expect(resp.body).to be_a(String)
      end
    end

    context 'attempting to set an invalid property' do
      let(:item_id) { Faker::Internet.uuid }

      it 'raises a WrongData' do
        expect do
          subject.partial_update_item_bulk(
            items: [
              {
                item_id: item_id,
                invalid: 'INVALID'
              }
            ],
            create_if_missing: true
          )
        end.to raise_error(
          an_instance_of(Xminds::ResponseError).and having_attributes(
            error_name: 'WrongData',
            error_data: {
              error: 'unknown property "invalid" with "repeated=False". Available: [\'test_item_property\']',
              name: 'WRONG_DATA_TYPE'
            }
          )
        )
      end
    end

    context 'when two items with the same item_id are attempting to be updated' do
      let(:item_id) { Faker::Internet.uuid }
      let(:property_value1) { Faker::Number.within(range: 1..100) }
      let(:property_value2) { property_value1 + 5 }

      it 'raises a DuplicatedError' do
        expect do
          subject.partial_update_item_bulk(
            items: [
              {
                item_id: item_id,
                property_name => property_value1
              }, {
                item_id: item_id,
                property_name => property_value2
              }
            ],
            create_if_missing: true
          )
        end.to raise_error(
          an_instance_of(Xminds::ResponseError).and having_attributes(
            error_name: 'DuplicatedError',
            error_data: {
              type: 'item',
              key: nil,
              name: 'DUPLICATED_ITEM_ID'
            }
          )
        )
      end
    end
  end

  describe '#list_all_items' do
    context 'on success' do
      it 'returns the items' do
        resp = subject.list_all_items(amount: 1, cursor: 2)

        expect(resp).to be_a(Xminds::Response)
        expect(resp.items).to be_a(Array)
      end
    end
  end

  describe '#list_all_itemss_by_id' do
    let(:item_ids) { Array.new(3) { Faker::Internet.uuid } }

    before(:each) { item_ids.each { |item_id| create_or_update_item(item_id) } }

    context 'on success' do
      it 'returns the items' do
        resp = subject.list_all_items_by_id(item_ids: item_ids)

        expect(resp).to be_a(Xminds::Response)
        expect(resp.items.count).to be(item_ids.count)
      end
    end
  end
end

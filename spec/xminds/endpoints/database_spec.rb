# frozen_string_literal: true

RSpec.describe Xminds::Endpoints::Database do
  before(:all) { reset_test_account }

  subject { described_class.new(endpoint: endpoint, jwt_token: jwt_token) }

  describe '#create_database' do
    context 'on success' do
      let(:test_create_database_name) { 'xminds_rspec_create_test_database' }

      before(:each) { delete_db_by_name(test_create_database_name) }
      after(:each) { delete_db_by_name(test_create_database_name) }

      it 'creates the new database' do
        resp = subject.create_database(
          database_name: test_create_database_name,
          description: 'Xminds RSPEC test create database',
          item_id_type: 'uint32',
          user_id_type: 'uint32'
        )

        expect(resp).to be_a(Xminds::Response)
        expect(resp.id).to be_a(String)
      end
    end

    context 'when database with same name already exists' do
      it 'raises a DuplicatedError' do
        expect do
          subject.create_database(
            database_name: test_database_name,
            description: 'Xminds RSPEC test database',
            item_id_type: 'uint32',
            user_id_type: 'uint32'
          )
        end.to raise_error(
          an_instance_of(Xminds::ResponseError).and having_attributes(
            error_name: 'DuplicatedError',
            error_data: {
              type: 'db-metadata',
              key: nil,
              name: 'DUPLICATED_DB_NAME'
            }
          )
        )
      end
    end
  end

  describe '#list_all_databases' do
    context 'without pagination' do
      it 'returns all the databases' do
        resp = subject.list_all_databases

        expect(resp).to be_a(Xminds::Response)
        expect(resp.databases.count).to be_a(Integer)
        expect(resp.databases.map(&:name)).to include(test_database_name)
      end
    end

    context 'with pagination' do
      it 'returns the paginated databases' do
        resp = subject.list_all_databases(page: 1, amount: 20)

        expect(resp).to be_a(Xminds::Response)
        expect(resp.databases.count).to be_a(Integer)
        expect(resp.databases.map(&:name)).to include(test_database_name)
      end
    end
  end

  describe '#current_database' do
    context 'on success' do
      it 'returns the current database' do
        resp = subject.current_database

        expect(resp).to be_a(Xminds::Response)
        expect(resp.name).to eq(test_database_name)
      end
    end
  end

  describe '#delete_current_database' do
    let(:test_delete_database_name) { 'xminds_rspec_delete_test_database' }

    before(:each) { delete_db_by_name(test_delete_database_name) }
    after(:each) { delete_db_by_name(test_delete_database_name) }

    let(:test_delete_database_id) do
      client.create_database(
        database_name: test_delete_database_name,
        description: 'Xminds RSPEC test delete database',
        item_id_type: 'uint32',
        user_id_type: 'uint32'
      ).id
    end

    let(:test_delete_database_jwt) do
      Xminds::Client.new(
        type: :service,
        endpoint: endpoint,
        service_name: test_accout_service_name,
        password: test_account_password,
        database_id: test_delete_database_id
      ).jwt_token
    end

    subject { described_class.new(endpoint: endpoint, jwt_token: test_delete_database_jwt) }

    context 'on success' do
      it 'deletes the current database' do
        resp = subject.delete_current_database

        expect(resp).to be_a(Xminds::Response)
      end
    end
  end

  describe '#current_database_status' do
    context 'on success' do
      it 'returns the current database status' do
        resp = subject.current_database_status

        expect(resp).to be_a(Xminds::Response)
        expect(resp.status).to eq('pending')
      end
    end
  end
end

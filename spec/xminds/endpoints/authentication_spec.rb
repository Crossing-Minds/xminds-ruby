# frozen_string_literal: true

RSpec.describe Xminds::Endpoints::Authentication do
  let(:email) { 'xminds_rspec_test_account@crossingminds.com' }
  let(:service_name) { 'test_service' }

  let(:create_new_individual_account_proc) do
    -> do
      root_client.create_individual_account(
        email: email,
        password: 'MyP@ssw0rd',
        role: :manager,
        first_name: 'Individual',
        last_name: 'Account'
      )
    end
  end

  let(:create_new_service_account_proc) do
    -> do
      root_client.create_service_account(
        service_name: service_name,
        password: 'MyP@ssw0rd_1',
        role: :manager
      )
    end
  end

  let(:root_client) { described_class.new(endpoint: endpoint, jwt_token: client.jwt_token) }

  subject { root_client }

  describe '#list_all_accounts' do
    context 'on success' do
      it 'returns all accounts' do
        resp = subject.list_all_accounts

        expect(resp).to be_a(Xminds::Response)
        expect(resp.individual_accounts).to be_a(Array)
        expect(resp.service_accounts).to be_a(Array)
      end
    end
  end

  describe '#create_individual_account' do
    before(:each) { delete_individual_account(email: email) }

    after(:each) { delete_individual_account(email: email) }

    context 'on success' do
      it 'creates an individual account' do
        resp = create_new_individual_account_proc.call

        expect(resp).to be_a(Xminds::Response)
        expect(resp.id).to be_a(String)
      end
    end

    context 'on duplicate account failure' do
      it 'raises a Xminds response error' do
        create_new_individual_account_proc.call

        expect { create_new_individual_account_proc.call }.to raise_error(
          an_instance_of(Xminds::ResponseError).and having_attributes(error_name: 'DuplicatedError')
        )
      end
    end
  end

  describe '#delete_individual_account' do
    after(:each) { delete_individual_account(email: email) }

    context 'on success' do
      before(:each) { create_new_individual_account_proc.call }

      it 'deletes the account' do
        resp = subject.delete_individual_account(email: email)

        expect(resp).to be_a(Xminds::Response)
      end
    end

    context 'on account not found failure' do
      it 'raises a Xminds response error' do
        expect { subject.delete_individual_account(email: email) }.to raise_error(
          an_instance_of(Xminds::ResponseError).and having_attributes(error_name: 'NotFoundError')
        )
      end
    end
  end

  describe '#create_service_account' do
    before(:each) { delete_service_account(service_name: service_name) }

    after(:each) { delete_service_account(service_name: service_name) }

    context 'on success' do
      it 'creates a service account' do
        resp = create_new_service_account_proc.call

        expect(resp).to be_a(Xminds::Response)
        expect(resp.id).to be_a(String)
      end
    end

    context 'on duplicate account failure' do
      it 'raises a Xminds response error' do
        create_new_service_account_proc.call

        expect { create_new_service_account_proc.call }.to raise_error(
          an_instance_of(Xminds::ResponseError).and having_attributes(error_name: 'DuplicatedError')
        )
      end
    end
  end

  describe '#delete_service_account' do
    before(:each) { delete_service_account(service_name: service_name) }

    context 'on success' do
      before(:each) { create_new_service_account_proc.call }

      it 'deletes the account' do
        resp = subject.delete_service_account(service_name: service_name)

        expect(resp).to be_a(Xminds::Response)
      end
    end

    context 'on account not found failure' do
      it 'raises a Xminds response error' do
        expect { subject.delete_service_account(service_name: service_name) }.to raise_error(
          an_instance_of(Xminds::ResponseError).and having_attributes(error_name: 'NotFoundError')
        )
      end
    end
  end

  describe '#login_as_individual' do
    before(:each) { create_new_individual_account_proc.call }
    after(:each) { delete_individual_account(email: email) }

    context 'on success' do
      before(:each) { root_client.verify_email(email: email, code: '988440ade91cd4c98eceb58db1c3f76bb902753c') }

      it 'returns a login response' do
        resp = subject.login_as_individual(
          email: email,
          password: 'MyP@ssw0rd',
          database_id: test_database_id
        )

        expect(resp).to be_a(Xminds::Response)
        expect(resp.token).to be_a(String)
        expect(resp.refresh_token).to be_a(String)
        expect(resp.database.id).to eq(test_database_id)
      end
    end

    context 'on wrong password failure' do
      before(:each) { root_client.verify_email(email: email, code: '988440ade91cd4c98eceb58db1c3f76bb902753c') }

      it 'raises a AuthError' do
        expect do
          subject.login_as_individual(
            email: email,
            password: 'WRONGPASS',
            database_id: test_database_id
          )
        end.to raise_error(
          having_attributes(
            error_name: 'AuthError',
            error_data: {
              error: 'account password is incorrect',
              name: 'INCORRECT_PASSWORD'
            }
          )
        )
      end
    end

    context 'on account not verified' do
      it 'raises a AuthError' do
        expect do
          subject.login_as_individual(
            email: email,
            password: 'MyP@ssw0rd',
            database_id: test_database_id
          )
        end.to raise_error(
          an_instance_of(Xminds::ResponseError).and(
            having_attributes(
              error_name: 'AuthError',
              error_data: {
                error: 'this account is not verified',
                name: 'ACCOUNT_NOT_VERIFIED'
              }
            )
          )
        )
      end
    end
  end

  describe '#login_as_service' do
    before(:each) { create_new_service_account_proc.call }
    after(:each) { delete_service_account(service_name: service_name) }

    context 'on success' do
      it 'returns a login response' do
        resp = subject.login_as_service(
          service_name: service_name,
          password: 'MyP@ssw0rd_1',
          database_id: test_database_id
        )

        expect(resp).to be_a(Xminds::Response)
        expect(resp.token).to be_a(String)
        expect(resp.refresh_token).to be_a(String)
        expect(resp.database.id).to eq(test_database_id)
      end
    end

    context 'on wrong password failure' do
      it 'raises a AuthError' do
        expect do
          subject.login_as_service(
            service_name: service_name,
            password: 'WRONGPASS',
            database_id: test_database_id
          )
        end.to raise_error(
          an_instance_of(Xminds::ResponseError).and(
            having_attributes(
              error_name: 'AuthError',
              error_data: {
                error: 'account password is incorrect',
                name: 'INCORRECT_PASSWORD'
              }
            )
          )
        )
      end
    end
  end

  describe '#login_as_root' do
    context 'on success' do
      it 'returns a JWT token' do
        resp = subject.login_as_root(
          email: root_email,
          password: root_password
        )

        expect(resp).to be_a(Xminds::Response)
        expect(resp.token).to be_a(String)
      end
    end

    context 'on wrong password failure' do
      it 'raises a AuthError' do
        expect do
          subject.login_as_root(
            email: root_email,
            password: 'WRONGPASS'
          )
        end.to raise_error(
          an_instance_of(Xminds::ResponseError).and having_attributes(
            error_name: 'AuthError',
            error_data: {
              name: 'INCORRECT_PASSWORD',
              error: 'account password is incorrect'
            }
          )
        )
      end
    end
  end

  describe '#renew_login_with_refresh_token' do
    before(:each) do
      delete_individual_account(email: email)
      create_new_individual_account_proc.call
      root_client.verify_email(email: email, code: '988440ade91cd4c98eceb58db1c3f76bb902753c')
    end

    let(:individual_client) do
      root_client.login_as_individual(
        email: email,
        password: 'MyP@ssw0rd',
        database_id: test_database_id
      )
    end

    let(:refresh_token) { individual_client.refresh_token }

    subject { described_class.new(endpoint: endpoint, jwt_token: jwt_token) }

    context 'on success' do
      it 'returns a new JWT and refresh token' do
        resp = subject.renew_login_with_refresh_token(refresh_token: refresh_token)

        expect(resp).to be_a(Xminds::Response)
        expect(resp.token).to be_a(String)
        expect(resp.token).to_not eq(individual_client.jwt_token)
        expect(resp.refresh_token).to be_a(String)
      end
    end

    context 'when refresh token is invalid' do
      it 'raises a AuthError' do
        expect do
          subject.renew_login_with_refresh_token(refresh_token: 'INVALID')
        end.to raise_error(
          an_instance_of(Xminds::ResponseError).and having_attributes(
            error_name: 'AuthError',
            error_data: {
              error: 'refresh token is incorrect or invalidated',
              name: 'INCORRECT_REFRESH_TOKEN'
            }
          )
        )
      end
    end

    context 'when account has been deleted' do
      before(:each) { delete_individual_account(email: email) }

      it 'raises a NotFoundError' do
        expect do
          subject.renew_login_with_refresh_token(refresh_token: refresh_token)
        end.to raise_error(
          an_instance_of(Xminds::ResponseError).and having_attributes(
            error_name: 'NotFoundError',
            error_data: {
              type: 'account',
              key: email,
              name: 'ACCOUNT_NOT_FOUND'
            }
          )
        )
      end
    end
  end

  describe '#resend_email_verification_code' do
    before(:each) do
      delete_individual_account(email: email)
      create_new_individual_account_proc.call
    end

    after(:each) { delete_individual_account(email: email) }

    context 'on success' do
      it 'resends the email verification code' do
        resp = subject.resend_email_verification_code(email: email)

        expect(resp).to be_a(Xminds::Response)
        expect(resp.body).to be_a(String)
      end
    end

    context 'when the email does not exist' do
      it 'raises a NotFoundError error' do
        expect do
          subject.resend_email_verification_code(email: 'invalid.email@user.com')
        end.to raise_error(
          an_instance_of(Xminds::ResponseError).and having_attributes(
            error_name: 'NotFoundError',
            error_data: {
              type: 'account',
              key: 'invalid.email@user.com',
              name: 'ACCOUNT_NOT_FOUND'
            }
          )
        )
      end
    end

    context 'when the email has already been verified' do
      before(:each) { subject.verify_email(email: email, code: '988440ade91cd4c98eceb58db1c3f76bb902753c') }

      it 'raises a AuthError' do
        expect do
          subject.resend_email_verification_code(email: email)
        end.to raise_error(
          an_instance_of(Xminds::ResponseError).and having_attributes(
            error_name: 'AuthError',
            error_data: {
              error: 'the account None is already verified',
              name: 'ACCOUNT_ALREADY_VERIFIED'
            }
          )
        )
      end
    end
  end

  describe '#verify_email' do
    before(:each) do
      delete_individual_account(email: email)
      create_new_individual_account_proc.call
    end

    after(:each) { delete_individual_account(email: email) }

    context 'on success' do
      after(:each) { delete_individual_account(email: email) }
      it "verifies the user's email" do
        resp = subject.verify_email(
          email: email,
          code: '988440ade91cd4c98eceb58db1c3f76bb902753c'
        )
        @expected = { 
          :email  => email,
          :verified    => true
        }.to_json
        # assertions
        expect(resp).to be_a(Xminds::Response)
        resp.should == @expected
      end
    end

    context 'when the email is invalid' do
      it 'raises a NotFoundError error' do
        expect do
          subject.verify_email(
            email: 'invalid.email@user.com',
            code: '988440ade91cd4c98eceb58db1c3f76bb902753c'
          )
        end.to raise_error(
          an_instance_of(Xminds::ResponseError).and having_attributes(
            error_name: 'NotFoundError',
            error_data: {
              type: 'account',
              key: 'invalid.email@user.com',
              name: 'ACCOUNT_NOT_FOUND'
            }
          )
        )
      end
    end

    context 'when the code is invalid' do
      it 'raises a AuthError' do
        expect do
          subject.verify_email(
            email: email,
            code: 'a5885ba31122009f0fb616f76edce5caeb8f148c'
          )
        end.to raise_error(
          an_instance_of(Xminds::ResponseError).and having_attributes(
            error_name: 'AuthError',
            error_data: {
              error: 'the activation code does not match',
              name: 'ACTIVATION_CODE_DOES_NOT_MATCH'
            }
          )
        )
      end
    end
  end

  describe '#delete_current_account' do
    before(:each) do
      delete_individual_account(email: email)
      create_new_individual_account_proc.call
      root_client.verify_email(email: email, code: '988440ade91cd4c98eceb58db1c3f76bb902753c')
    end

    after(:each) { delete_service_account(service_name: service_name) }

    subject do
      jwt_token = root_client.login_as_individual(
        email: email,
        password: 'MyP@ssw0rd',
        database_id: test_database_id
      ).token

      described_class.new(endpoint: endpoint, jwt_token: jwt_token)
    end

    context 'on success' do
      it 'deletes the current account' do
        resp = subject.delete_current_account

        expect(resp).to be_a(Xminds::Response)
      end
    end
  end
end

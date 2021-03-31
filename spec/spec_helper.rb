# frozen_string_literal: true

require 'bundler/setup'
require 'dotenv/load'
require 'faker'

require 'xminds'

require File.join(File.expand_path(__dir__), 'helpers/client_helpers')

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = '.rspec_status'

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.include ClientHelpers

  config.before(:suite) do
    helpers = Class.new.extend(ClientHelpers)

    helpers.delete_test_account

    helpers.create_test_account
    helpers.create_new_test_db
  end

  config.after(:suite) do
    helpers = Class.new.extend(ClientHelpers)

    helpers.delete_test_database
    helpers.delete_test_account
  end
end

# frozen_string_literal: true

require 'faker'

module ClientHelpers
  RSPEC_DB_NAME             = ENV.fetch('XMINDS_API_RSPEC_DB_NAME', 'xminds_rspec_test_database').freeze
  RSPEC_NOT_READY_DB_NAME   = 'xminds_rspec_recommendations_not_ready_test_database'
  ENDPOINT                  = ENV.fetch('XMINDS_API_TEST_ENDPOINT').freeze
  ROOT_EMAIL                = ENV.fetch('XMINDS_API_ROOT_EMAIL').freeze
  ROOT_PASSWORD             = ENV.fetch('XMINDS_API_ROOT_PASSWORD').freeze
  TEST_ACCOUNT_SERVICE_NAME = 'xminds_rspec_test_account'
  TEST_ACCOUNT_PASSWORD     = Faker::Internet.password.freeze

  def root_client
    @root_client ||= Xminds::Client.new(
      endpoint: endpoint,
      email: root_email,
      password: root_password
    )
  end

  def reset_test_account
    delete_test_account
    create_test_account

    @client = nil
  end

  def create_test_account
    root_client.create_service_account(
      service_name: test_accout_service_name,
      password: test_account_password,
      role: :manager
    )
  end

  def delete_test_account
    delete_service_account(service_name: test_accout_service_name)
  end

  def delete_individual_account(email:)
    return unless root_client.list_all_accounts.individual_accounts.map(&:email).include?(email)

    root_client.delete_individual_account(email: email)
  end

  def delete_service_account(service_name:)
    return unless root_client.list_all_accounts.service_accounts.map(&:name).include?(service_name)

    root_client.delete_service_account(service_name: service_name)
  end

  def client
    @client ||= Xminds::Client.new(
      type: :service,
      endpoint: endpoint,
      service_name: test_accout_service_name,
      password: test_account_password,
      database_id: test_database_id
    )
  end

  def client_for_db(database_name)
    Xminds::Client.new(
      type: :service,
      endpoint: endpoint,
      service_name: test_accout_service_name,
      password: test_account_password,
      database_id: find_database_by_name(database_name).id
    )
  end

  def create_new_test_db
    delete_test_database

    @@test_database_id = root_client.create_database(
      database_name: test_database_name,
      description: "Xminds test database created by RSPEC at #{__FILE__}:#{caller.first.split(':')[1]}",
      item_id_type: 'uuid',
      user_id_type: 'uuid'
    ).id
  end

  def recommendation_not_ready_client
    @recommendation_not_ready_client ||= client_for_db(test_not_ready_database_name)
  end

  def create_new_recommendation_not_ready_test_db
    delete_new_recommendation_not_ready_test_db

    root_client.create_database(
      database_name: test_not_ready_database_name,
      description: "Xminds test database created by RSPEC at #{__FILE__}:#{caller.first.split(':')[1]}",
      item_id_type: 'uuid',
      user_id_type: 'uuid'
    )

    recommendation_not_ready_client.create_item_property(property_name: 'item_property', value_type: 'int8')
    recommendation_not_ready_client.create_user_property(property_name: 'user_property', value_type: 'int8')
  end

  def delete_new_recommendation_not_ready_test_db
    delete_db_by_name(test_not_ready_database_name)
  end

  def test_database
    @test_database ||= find_database_by_name(test_database_name)
  end

  def delete_db_by_name(database_name)
    return unless (database = find_database_by_name(database_name))

    Xminds::Client.new(
      type: :service,
      endpoint: endpoint,
      service_name: test_accout_service_name,
      password: test_account_password,
      database_id: database.id
    ).delete_current_database
  end

  def find_database_by_name(database_name)
    root_client.list_all_databases.databases.find { |db| db.name == database_name }
  end

  def create_user_property(property_name, value_type)
    delete_user_property(property_name)

    client.create_user_property(property_name: property_name, value_type: value_type)
  end

  def create_item_property(property_name, value_type)
    delete_item_property(property_name)

    client.create_item_property(property_name: property_name, value_type: value_type)
  end

  def delete_user_property(property_name)
    return unless client.list_all_user_properties.properties.map(&:property_name).include?(property_name)

    client.delete_user_property(property_name: property_name)
  end

  def delete_item_property(property_name)
    return unless client.list_all_item_properties.properties.map(&:property_name).include?(property_name)

    client.delete_item_property(property_name: property_name)
  end

  def create_or_update_user(user_id, **user)
    client.create_or_update_user(user_id: user_id, user: user)
  end

  def create_or_update_item(item_id, **item)
    client.create_or_update_item(item_id: item_id, item: item)
  end

  def seed_recommendations
    puts 'seeding database for recommendation specs'
    seed_user_properties
    seed_item_properties
    seed_users
    seed_items
    seed_ratings
    puts 'successfully seeded database for recommendation specs'
  end

  def seed_user_properties
    user_properties = [
      { property_name: 'age', value_type: 'int8' },
      { property_name: 'job_field', value_type: 'unicode' },
      { property_name: 'animal', value_type: 'unicode' },
      { property_name: 'favorite_movie', value_type: 'unicode' }
    ]

    existing_user_property_names = client.list_all_user_properties.properties.map(&:property_name)

    user_properties.each do |user_property|
      property_name, value_type = user_property.values

      next if existing_user_property_names.include?(property_name)

      client.create_user_property(property_name: property_name, value_type: value_type)
    end
  end

  def seed_item_properties
    item_properties = [
      { property_name: 'title', value_type: 'unicode' },
      { property_name: 'author', value_type: 'unicode' },
      { property_name: 'publisher', value_type: 'unicode' },
      { property_name: 'genre', value_type: 'unicode' }
    ]

    existing_item_property_names = client.list_all_item_properties.properties.map(&:property_name)

    item_properties.each do |item_property|
      property_name, value_type = item_property.values

      next if existing_item_property_names.include?(property_name)

      client.create_item_property(property_name: property_name, value_type: value_type)
    end
  end

  def seed_users(count = 50)
    existing_users = client.list_all_users.users

    count -= existing_users.count

    return unless count.positive?

    users = Array.new(count) do
      {
        user_id: Faker::Internet.uuid,
        age: Faker::Number.within(range: 5..100),
        job_field: Faker::Job.field,
        animal: Faker::Creature::Animal.name,
        favorite_movie: Faker::Movie.title
      }
    end

    client.create_or_update_user_bulk(users: users)
  end

  def seed_items(count = 50)
    existing_items = client.list_all_items.items

    count -= existing_items.count

    return unless count.positive?

    items = Array.new(count) do
      {
        item_id: Faker::Internet.uuid,
        title: Faker::Book.title,
        author: Faker::Book.author,
        publisher: Faker::Book.publisher,
        genre: Faker::Book.genre
      }
    end

    client.create_or_update_item_bulk(items: items)
  end

  def seed_ratings(count = 500)
    users            = client.list_all_users.users.map(&:user_id)
    items            = client.list_all_items.items.map(&:item_id)
    existing_ratings = client.list_all_ratings(amount: count).ratings

    count -= existing_ratings.count

    return unless count.positive?

    ratings = users.product(items).sample(count).map do |user_id, item_id|
      { user_id: user_id, item_id: item_id, rating: Faker::Number.within(range: 1.0..5.0), timestamp: Time.now.to_i }
    end

    client.create_or_update_ratings_bulk(ratings: ratings)
  end

  def wait_for_database_to_be_ready!
    puts 'waiting for testing database to reach ready state'

    sleep 15

    15.times do |i|
      return if client.current_database_status.status == 'ready'

      sleep 5
    end

    raise StandardError, 'Database failed to reach ready state.'
  end

  # rubocop:disable Layout/EmptyLineBetweenDefs, Style/SingleLineMethods
  def root_email; ROOT_EMAIL end
  def endpoint; ENDPOINT end
  def jwt_token; client.jwt_token end
  def root_password; ROOT_PASSWORD end
  def test_database_id; @@test_database_id end
  def test_database_name; RSPEC_DB_NAME end
  def test_not_ready_database_name; RSPEC_NOT_READY_DB_NAME end
  def delete_test_database; delete_db_by_name(test_database_name) && @test_database = nil end
  def test_accout_service_name; TEST_ACCOUNT_SERVICE_NAME end
  def test_account_password; TEST_ACCOUNT_PASSWORD end
  # rubocop:enable Layout/EmptyLineBetweenDefs, Style/SingleLineMethods
end

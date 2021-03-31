# Xminds

Ruby client for Crossing Minds API

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'xminds'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install xminds

## Usage

By default, the library is configured to use Crossing Minds primary endpoint - https://api.crossingminds.com - as the endpoint and accepts configuration values needed for the specific account type to create the client: endpoint, email, password, database ID, service name, and frontend user ID from the following environment variables: `XMINDS_API_ENDPOINT`, `XMINDS_API_EMAIL`, `XMINDS_API_PWD`, `XMINDS_API_DATABASE_ID`, `XMINDS_API_SERVICE_NAME`, and `XMINDS_API_FRONTEND_USER_ID`. To configure the library differently:

```ruby
Xminds.configure do |config|
  config.endpoint         = 'https://api.crossingminds.com' # overwrites defaults of https://api.crossingminds.com and $XMINDS_API_ENDPOINT
  config.email            = 'example.user@xminds.com'       # overwrites default of $XMINDS_API_EMAIL
  config.password         = 'MyP@ssw0rd'                    # overwrites default of $XMINDS_API_PWD
  config.database_id      = 'wSSZQbPxKvBrk_n2B_m6ZA'        # overwrites default of $XMINDS_API_DATABASE_ID
  config.service_name     = 'Example DB name'               # overwrites default of $XMINDS_API_SERVICE_NAME
  config.frontend_user_id = 12358                           # overwrites default of $XMINDS_API_FRONTEND_USER_ID
end
```

## Examples

Here is an example on how to setup the configuration with an initializer, then create a root client and list all accounts.

```ruby
# global initializer
Xminds.configure do |config|
  config.email = 'root.account@example.com'
  password     = 'MyP@ssw0rd'
end

# client creation (defaults to root) and usage
client = Xminds::Client.new

client.list_all_accounts
```

Here is an example on how to setup an individual client without a configuration.

```ruby
client = Xminds::Client.new(
  type: :individual,
  email: 'individual.account@example.com',
  password: 'MyP@ssw0rd',
  database_id: 'wSSZQbPxKvBrk_n2B_m6ZA',
  frontend_user_id: '5906d464-7ef1-4377-96e3-529f2ed6721d' # optional
)

client.list_all_accounts
```

Or a service account without a configuration.

```ruby
client = Xminds::Client.new(
  type: :service,
  service_name: 'myapp-web',
  password: 'MyP@ssw0rd',
  database_id: 'wSSZQbPxKvBrk_n2B_m6ZA',
  frontend_user_id: '5906d464-7ef1-4377-96e3-529f2ed6721d' # optional
)

client.list_all_accounts
```

## Supported Endpoints

All of [Crossing Minds endpoints are supported](https://docs.api.crossingminds.com/endpoints/) by this gem.

| Object                                                                                        | Action                                             | Method                                                                                                                                                 |
|-----------------------------------------------------------------------------------------------|----------------------------------------------------|--------------------------------------------------------------------------------------------------------------------------------------------------------|
| [Authentication](https://docs.api.crossingminds.com/endpoints/account.html)                   | [GET] List all accounts                            | Client#list_all_accounts                                                                                                                               |
|                                                                                               | [POST] Create individual account                   | Client#create_individual_account(email:, password:, role:, first_name:, last_name:)                                                                    |
|                                                                                               | [DELETE] Delete individual account                 | Client#delete_individual_account(email:)                                                                                                               |
|                                                                                               | [POST] Create service account                      | Client#create_service_account(service_name:, password:, role:)                                                                                         |
|                                                                                               | [DELETE] Delete service account                    | Client#delete_service_account(service_name:)                                                                                                           |
|                                                                                               | [POST] Login as individual account                 | Client#login_as_individual(email:, password:, database_id:, frontend_user_id: nil)                                                                     |
|                                                                                               | [POST] Login as service account                    | Client#login_as_service(service_name:, password:, database_id:, frontend_user_id: nil)                                                                 |
|                                                                                               | [POST] Login as root account                       | Client#login_as_root(email:, password:)                                                                                                                |
|                                                                                               | [POST] Renew login with refresh token              | Client#renew_login_with_refresh_token(refresh_token:)                                                                                                  |
|                                                                                               | [POST] Renew login with refresh token              | Client#resend_email_verification_code(email:)                                                                                                          |
|                                                                                               | [GET] Verify email                                 | Client#verify_email(email:, code:)                                                                                                                     |
|                                                                                               | [DELETE] Delete current account                    | Client#delete_current_account                                                                                                                          |
| [Database](https://docs.api.crossingminds.com/endpoints/database.html)                        | [POST] Create new database                         | Client#create_database(database_name:, description:, item_id_type:, user_id_type:)                                                                     |
|                                                                                               | [GET] List all databases                           | Client#list_all_databases(page: nil, amount: nil)                                                                                                      |
|                                                                                               | [GET] Get current database                         | Client#current_database                                                                                                                                |
|                                                                                               | [DELETE] Delete current database                   | Client#delete_current_database                                                                                                                         |
|                                                                                               | [GET] Get current database status                  | Client#current_database_status                                                                                                                         |
| [UsersDataAndProperties](https://docs.api.crossingminds.com/endpoints/user.html)              | [GET] List all user properties                     | Client#list_all_user_properties                                                                                                                        |
|                                                                                               | [POST] Create new user property                    | Client#create_user_property(property_name:, value_type:, repeated: false)                                                                              |
|                                                                                               | [GET] Get a user property                          | Client#get_user_property(property_name:)                                                                                                               |
|                                                                                               | [DELETE] Delete a user property                    | Client#delete_user_property(property_name:)                                                                                                            |
|                                                                                               | [GET] Get a user                                   | Client#get_user(user_id:)                                                                                                                              |
|                                                                                               | [PUT] Create or update a user                      | Client#create_or_update_user(user_id:, user:)                                                                                                          |
|                                                                                               | [PATCH] Partial update one user                    | Client#partial_update_user(user_id:, user:, create_if_missing: false)                                                                                  |
|                                                                                               | [PUT] Create or update users in bulk               | Client#create_or_update_user_bulk(users:)                                                                                                              |
|                                                                                               | [PATCH] Partial update many users in bulk          | Client#partial_update_user_bulk(users:, create_if_missing: false)                                                                                      |
|                                                                                               | [GET] List all users                               | Client#list_all_users(amount: nil, cursor: nil)                                                                                                        |
|                                                                                               | [POST] List all users by user ID                   | Client#list_all_users_by_id(user_ids:)                                                                                                                 |
| [ItemsDataAndProperties](https://docs.api.crossingminds.com/endpoints/item.html)              | [GET] List all item properties                     | Client#list_all_item_properties                                                                                                                        |
|                                                                                               | [POST] Create new item property                    | Client#create_item_property(property_name:, value_type:, repeated: false)                                                                              |
|                                                                                               | [GET] Get a item property                          | Client#get_item_property(property_name:)                                                                                                               |
|                                                                                               | [DELETE] Delete a item property                    | Client#delete_item_property(property_name:)                                                                                                            |
|                                                                                               | [GET] Get a item                                   | Client#get_item(item_id:)                                                                                                                              |
|                                                                                               | [PUT] Create or update a item                      | Client#create_or_update_item(item_id:, item:)                                                                                                          |
|                                                                                               | [PATCH] Partial update one item                    | Client#partial_update_item(item_id:, item:, create_if_missing: false)                                                                                  |
|                                                                                               | [PUT] Create or update items in bulk               | Client#create_or_update_item_bulk(items:)                                                                                                              |
|                                                                                               | [PATCH] Partial update many items in bulk          | Client#partial_update_item_bulk(items:, create_if_missing: false)                                                                                      |
|                                                                                               | [GET] List all items                               | Client#list_all_items(amount: nil, cursor: nil)                                                                                                        |
|                                                                                               | [POST] List all users by item ID                   | Client#list_all_items_by_id(item_ids:)                                                                                                                 |
| [UserRatings]                                                                                 | [PUT] Create or update a rating                    | Client#create_or_update_rating(user_id:, item_id:, rating:, timestamp: nil)                                                                            |
|                                                                                               | [DELETE] Delete a rating                           | Client#delete_rating(user_id:, item_id:)                                                                                                               |
|                                                                                               | [GET] List all ratings for a user                  | Client#list_all_ratings_for_user(user_id:, page: nil, amount: nil)                                                                                     |
|                                                                                               | [PUT] Create or update ratings for a user in bulk  | Client#create_or_update_ratings_for_user_bulk(user_id:, ratings:)                                                                                      |
|                                                                                               | [DELETE] Delete a ratings for a user               | Client#delete_all_ratings_for_user(user_id:)                                                                                                           |
|                                                                                               | [PUT] Create or update ratings in bulk             | Client#create_or_update_ratings_bulk(ratings:)                                                                                                         |
|                                                                                               | [GET] List all ratings                             | Client#list_all_ratings(amount: nil, cursor: nil)                                                                                                      |
| [UserInteractions](https://docs.api.crossingminds.com/endpoints/userinteraction.html)         | [POST] Create one interaction                      | Client#create_user_interaction(user_id:, item_id:, interaction_type:, timestamp: nil)                                                                  |
|                                                                                               | [POST] Create interactions for many users in bulk  | Client#create_user_interactions_bulk(interactions:)                                                                                                    |
| [Recommendation](https://docs.api.crossingminds.com/endpoints/reco.html)                      | [GET] List recommendations for similar items       | Client#list_similar_item_recommendations(item_id:, amount: nil, cursor: nil, filters: nil)                                                             |
|                                                                                               | [GET] List recommendations for session based items | Client#list_session_based_item_recommendations(amount: nil, cursor: nil, filters: nil, ratings: nil, user_properties: nil, exclude_rated_items: false) |
|                                                                                               | [GET] List recommendations for profile based items | Client#list_profile_based_item_recommendations(user_id:, amount: nil, cursor: nil, filters: nil, exclude_rated_items: false)                           |
| [BackgroundTasks](https://docs.api.crossingminds.com/endpoints/task.html)                     | [POST] Trigger a background task                   | Client#trigger_background_task(task_name:)                                                                                                             |
|                                                                                               | [GET] List recent background tasks                 | Client#list_recent_background_tasks(task_name:)                                                                                                        |

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/Crossing-Minds/xminds-ruby.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

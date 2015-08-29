lock '3.4.0'

set :application, 'hellotoken-rails'
set :repo_url, 'git@github.com:lswang1618/hellotoken-rails.git'
# set :branch, "master"

set :deploy_to, "/var/www/#{fetch(:application)}"
# set :deploy_user, "ht-deployer" (set in specific stage files instead)

set :linked_files, %w{config/database.yml config/secrets.yml config/paypal.yml}
set :linked_dirs, %w{log tmp/pids tmp/cache tmp/sockets vendor/bundle public/system}

# # Default value for keep_releases is 5
set :keep_releases, 3



set :stage, :production
set :rails_env, 'production'
set :deploy_user, "ht-deployer"

server '104.236.62.120', user: 'ht-deployer', port: '22', roles: %w{web app db}, primary: true

set :stage, :staging
set :branch, ENV.fetch("CAPISTRANO_BRANCH", "master")

server '159.89.3.23', user: 'deploy', roles: %w{web app}

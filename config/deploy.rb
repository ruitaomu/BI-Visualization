require 'mina/bundler'
require 'mina/rails'
require 'mina/git'
# require 'mina/rbenv'

set :domain, 'bi.prd'
set :deploy_to, '/home/deploy/bi'
set :repository, 'git@bitbucket.org:paxx/brainintelligence.git'
set :branch, 'master'

# Manually create these paths in shared/ (eg: shared/config/database.yml) in your server.
# They will be linked in the 'deploy:link_shared_paths' step.
set :shared_paths, %w(config/database.yml log .env.production)

set :user, 'deploy'
set :forward_agent, true
set :env_vars, 'PATH=/usr/local/rbenv/shims:/usr/local/rbenv/bin:$PATH'

task :environment do
  # invoke :'rbenv:load'
end

task setup: :environment do
  queue! %[mkdir -p "#{deploy_to}/#{shared_path}/log"]
  queue! %[chmod g+rx,u+rwx "#{deploy_to}/#{shared_path}/log"]

  queue! %[mkdir -p "#{deploy_to}/#{shared_path}/config"]
  queue! %[chmod g+rx,u+rwx "#{deploy_to}/#{shared_path}/config"]

  queue! %[touch "#{deploy_to}/#{shared_path}/config/database.yml"]
  queue  %[echo "-----> Be sure to edit '#{deploy_to}/#{shared_path}/config/database.yml'."]

  queue! %[touch "#{deploy_to}/#{shared_path}/.env.production"]
  queue  %[echo "-----> Be sure to edit '#{deploy_to}/#{shared_path}/.env.production'."]
end

namespace :bower do
  task :install do
    queue "echo '-----> Installing Assets with Bower...'"
    queue 'bower install > /dev/null'
  end
end

desc 'Deploys the current version to the server.'
task deploy: :environment do
  to :before_hook do
    # Put things to run locally before ssh
  end
  deploy do
    invoke :'git:clone'
    invoke :'deploy:link_shared_paths'
    invoke :'bundle:install'
    invoke :'rails:db_migrate'
    invoke :'bower:install'
    invoke :'rails:assets_precompile'
    invoke :'deploy:cleanup'

    to :launch do
      queue "mkdir -p #{deploy_to}/#{current_path}/tmp/"
      queue "touch #{deploy_to}/#{current_path}/tmp/restart.txt"
    end
  end
end

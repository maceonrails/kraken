# config/deploy/staging.rb
require 'mina/bundler'
require 'mina/rails'
require 'mina/git'
require 'mina/rvm'

#                                                                        Config
# ==============================================================================
set :term_mode,       :system
set :rails_env,       'staging'

set :domain,          '104.215.153.222'
set :port,            37894

set :deploy_to,       "/home/azureuser/mfp/#{rails_env}"
set :app_path,        "#{deploy_to}/#{current_path}"

set :repository,      'https://github.com/evandavid/kraken.git'
set :brach,           'master'

set :user,            'azureuser'
set :shared_paths,    ['public/static', 'tmp']
set :keep_releases,   5

#                                                                           RVM
# ==============================================================================
set :rvm_path, '/usr/local/rvm/scripts/rvm'

task :environment do
  invoke 'rvm:use[2.1.6]'
end

#                                                                    Setup task
# ==============================================================================
task :setup do
  queue! %{
    mkdir -p "#{deploy_to}/shared/tmp/pids"
  }
end

#                                                                   Deploy task
# ==============================================================================
desc "deploys the current version to the server."
task :deploy => :environment do
  deploy do
    invoke 'git:clone'
    invoke 'bundle:install'
    invoke 'rails:db_migrate'
    invoke 'rails:assets_precompile'
    invoke 'deploy:link_shared_paths'

    to :launch do
      invoke :'unicorn:restart'
    end
  end
end


#                                                                       Unicorn
# ==============================================================================
namespace :unicorn do
  set :unicorn_pid, "#{app_path}/tmp/pids/unicorn.pid"
  set :start_unicorn, %{
    cd #{app_path}
    bundle exec unicorn -c #{app_path}/config/unicorn/#{rails_env}.rb -E #{rails_env} -D
  }

#                                                                    Start task
# ------------------------------------------------------------------------------
  desc "Start unicorn"
  task :start => :environment do
    queue 'echo "-----> Start Unicorn"'
    queue! start_unicorn
  end

#                                                                     Stop task
# ------------------------------------------------------------------------------
  desc "Stop unicorn"
  task :stop do
    queue 'echo "-----> Stop Unicorn"'
    queue! %{
      test -s "#{unicorn_pid}" && kill -QUIT `cat "#{unicorn_pid}"` && echo "Stop Ok" && exit 0
      echo >&2 "Not running"
    }
  end

#                                                                  Restart task
# ------------------------------------------------------------------------------
  desc "Restart unicorn using 'upgrade'"
  task :restart => :environment do
    invoke 'unicorn:stop'
    invoke 'unicorn:start'
  end
end
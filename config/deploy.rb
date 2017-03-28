set :application, "powerdns-on-rails"

set :stages, %w(production development)

set :default_stage, "development"

require 'capistrano/ext/multistage'

set :repository,  "ssh://git.insales.ru/projects/powerdns-on-rails.git"

require "rvm/capistrano"                  # Load RVM's capistrano plugin.
set :rvm_ruby_string, "ruby-1.9.3-p547@powerdns-on-rails"
set :rvm_type, :user
set :rvm_install_ruby_threads, 4

require 'capistrano/ext/multistage'
require 'bundler/capistrano'

# If you aren't deploying to /u/apps/#{application} on the target
# servers (which is the default), you can specify the actual location
# via the :deploy_to variable:
# set :deploy_to, "/var/www/#{application}"

# If you aren't using Subversion to manage your source code, specify
# your SCM below:
set :scm, :git

set :git_enable_submodules, 1
set :deploy_via, :remote_cache

set :user, 'deploy'

set :use_sudo, false


shared_links = {
    'config/initializers/secret_token.rb' => 'config/initializers/secret_token.rb',
    'config/database.yml'             => 'config/database.yml',
    'locks'                           => 'locks'
  }.freeze

namespace :deploy do
  desc "Deploy"
  task :default do
    update
    finalize_update
    restart
#    cleanup
  end

  desc "Setup a GitHub-style deployment."
  task :setup, :except => { :no_release => true } do
    run "mkdir -p #{releases_path}/release"
    run "mkdir -p #{shared_path}"
    run "mkdir -p #{shared_path}/config"
    run "mkdir -p #{shared_path}/log"
    run "mkdir -p #{shared_path}/system"
    run "mkdir -p #{shared_path}/pids"
    run "git clone #{repository} #{releases_path}/release"
    run "ln -s #{releases_path}/release #{current_path}" 
  end

  desc "Update the deployed code."
  task :update_code, :except => { :no_release => true } do
    run "cd #{current_path}; git fetch origin; git reset --hard #{branch}"
  end

  desc "Finilize update."
  task :finalize_update, :except => { :no_release => true } do
    run <<-CMD
      rm -rf #{latest_release}/log #{latest_release}/public/system #{latest_release}/tmp/pids &&
      mkdir -p #{latest_release}/public &&
      mkdir -p #{latest_release}/tmp &&
      ln -s #{shared_path}/log #{latest_release}/log &&
      ln -s #{shared_path}/system #{latest_release}/public/system &&
      ln -s #{shared_path}/pids #{latest_release}/tmp/pids
    CMD
  end

  task :symlink_shared do
    commands = []
    shared_links.each do |from, to|
      commands << "(if [ ! -h #{latest_release}/#{to} ]; then rm -f #{latest_release}/#{to} && ln -s #{shared_path}/#{from} #{latest_release}/#{to}; fi)"
    end
      run commands.join(' && ')
  end
end

after "deploy:finalize_update", "deploy:symlink_shared"

Dir[File.join(File.dirname(__FILE__), '..', 'vendor', 'gems')].each do |vendored_notifier|
  $: << File.join(vendored_notifier, 'lib')
end

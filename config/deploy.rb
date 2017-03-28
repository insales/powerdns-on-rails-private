set :application, "powerdns-on-rails"

set :stages, %w(production development)

set :default_stage, "development"

# Деплоим не мастер, а конкретную версию чекаут которой сделан.
# При желании можно задать другую версию: cap -S branch="<branchname/commit_hash>" <action>
set :branch, fetch(:branch, `git describe --always`.chomp)

require "rvm/capistrano"                  # Load RVM's capistrano plugin.

# Capistrano должен использовать туже версию, которая используется при работе
# с проектом из консоли.
set :rvm_ruby_string, File.open('.ruby-version', 'rt').read.strip

set :rvm_type, :user
set :rvm_install_ruby_threads, 4

# Включаем ssh forward agent, чтобы пользователь мог ходить на github со своим ssh ключём.
set :ssh_options, { :forward_agent => true }

require 'capistrano/ext/multistage'
require 'bundler/capistrano'

set :repository,  "git@github.com:insales/powerdns-on-rails.git"

set :scm, :git

set :git_enable_submodules, 1
set :deploy_via, :remote_cache

set :user, 'deploy'

set :use_sudo, false

set :deploy_to, "/projects/cap/#{application}"

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
    run "mkdir -p #{releases_path}"
    run "test -d #{releases_path}/release || git clone #{repository} #{releases_path}/release"
    run "test -L #{current_path} || ln -s #{releases_path}/release #{current_path}"
    run "test -L /projects/#{application} || ln -s #{current_path} /projects/#{application}"

    # устанавливаем bundler т.к. его не будет на чистой системе
    run "bundler --version || gem install bundler"

    run "mkdir -p #{shared_path}"
    run "mkdir -p #{shared_path}/bundle"
    run "mkdir -p #{shared_path}/config"
    run "mkdir -p #{shared_path}/locks"
    run "mkdir -p #{shared_path}/log"
    run "mkdir -p #{shared_path}/pids"
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

# Переопределённый bundle:install, чтобы учитывался gemset
namespace :bundle do
  task :install do
    run "bash --login -c 'cd #{current_path} && gem install bundler && bundle install --quiet --frozen --without development test'"
    run "bash --login -c 'cd #{current_path} && rvm list'"
    run "bash --login -c 'cd #{current_path} && rvm gemset list'"
  end
end

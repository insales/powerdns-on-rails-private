set :deploy_to, "/projects/cap/#{application}"

set :branch, "origin/insales"

role :app, "bisu3.insales.ru", "h2.insales.ru"

namespace :deploy do
  task :restart do
    run "god restart powerdns-on-rails-unicorn"
  end
end

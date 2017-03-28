set :deploy_to, "/projects/cap/#{application}_dev"

set :branch, "origin/insales"

role :app, "nova.insales.ru"

namespace :deploy do
  task :application_tasks do
    run "cd #{current_path} && rake db:migrate"
  end

  task :restart do
    run "god restart pdns-dev-unicorn"
  end

end

after "deploy:update", "deploy:application_tasks"

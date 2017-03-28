role :app, 'powerdnsapp3.insales.ru', 'powerdnsapp6.insales.ru'
role :db,  'powerdnsapp3.insales.ru', primary: true

namespace :deploy do
  task :restart do
    run "god restart powerdns-on-rails-unicorn"
  end
end

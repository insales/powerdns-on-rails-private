# InSales fork of PowerDNS on Rails

## Деплой в продакшен через shipit

https://shipit.insales.ru/insales/powerdns-on-rails/production

## Деплой в продакшен через консоль

### Подготовка к деплою

- добавить себе в ~/.ssh/config настройки:

```
Host powerdnsapp3.insales.ru
    hostname 10.0.3.147
    ProxyCommand ssh -W %h:%p -q deploy@h3.insales.ru
    ForwardAgent yes

Host powerdnsapp6.insales.ru
    hostname 10.0.3.148
    ProxyCommand ssh -W %h:%p -q deploy@h6.insales.ru
    ForwardAgent yes
```

- запустить ssh-agent и добавить свой приватный ключ
```
eval `ssh-agent -s`
ssh-add
```

### Деплой

```
bundle exec cap production deploy
bundle exec cap production deploy:migrate
```

### Локальная разработка

database.yml
generate config/initializers/secret_token.rb

создать юзера:
```ruby
User.create email:"some.one@insales.ru", password:"123456", admin: true
```
по факту в проде авторизация идет через LDAP, а в dev - фолбек до локального пароля

Дамп прода (делать из офиса/vpn):
```sh
PGPASSWORD=.. pg_dump -Fc --host=138.201.51.2 --port=14016 --username=powerdns --exclude-table=audits powerdns > prod.dump
```

pg_restore --host=127.0.0.1 --port=5432 --clean --dbname=powerdns_development --username=postgres prod.dump

### Тесты

RSpec и Cucumber

```sh
rake spec
rake cucumber
```
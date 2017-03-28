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

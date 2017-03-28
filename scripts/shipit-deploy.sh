#!/bin/bash

eval `ssh-agent -s`
ssh-add ~/.ssh/id_ecdsa

echo --------------------------------------------
echo "RUN_MIGRATIONS:  $RUN_MIGRATIONS"
echo --------------------------------------------

if [[ "$RUN_MIGRATIONS" != "not_run" ]]; then
    bundle exec cap $ENVIRONMENT deploy:update
    bundle exec cap $ENVIRONMENT deploy:bundle_install
    bundle exec cap $ENVIRONMENT deploy:migrate
fi

bundle exec cap $ENVIRONMENT deploy

eval `ssh-agent -k`

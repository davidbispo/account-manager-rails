#!/usr/bin/env bash
rm -f tmp/pids/server.pid

bundle check > /dev/null 2>&1 || bundle install --local
RAILS_ENV=test bundle exec rake db:setup

if [ "$#" == 0 ]
then
    bundle exec rake db:migrate
    exec bundle exec rails s -p 3000 -b '0.0.0.0'
fi

exec $@
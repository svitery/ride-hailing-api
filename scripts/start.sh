#!/bin/sh

bundle install
bundle exec rake db:migrate
bundle exec rake db:seed
bundle exec rackup --host 0.0.0.0 -p 9292 config.ru

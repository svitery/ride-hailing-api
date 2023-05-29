#!/bin/sh

bundle install
bundle exec rake db:migrate
bundle exec rake db:test

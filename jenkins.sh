#!/bin/bash -x
export RAILS_ENV=test
export DISPLAY=":99"

bundle install --path "${HOME}/bundles/${JOB_NAME}" --deployment
bundle exec rake db:mongoid:drop
bundle exec rake db:schema:load
bundle exec rake
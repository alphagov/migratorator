# Configuration for the mongoid-history gem

Mongoid::History.tracker_class_name = :history_tracker

if Rails.env.test?
  Mongoid::History.current_user_method = :controller_name
else
  Mongoid::History.current_user_method = :current_user
end
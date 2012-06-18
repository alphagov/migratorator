class HistoryTracker
  include Mongoid::History::Tracker

  default_scope order_by([:created_at, :desc])
end
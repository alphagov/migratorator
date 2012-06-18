class RootController < ApplicationController

  # there's no magic here

  def index
    # load index.html.erb
    @revisions = HistoryTracker.limit(15).all
    @progress = Mapping.progress([], Tag::STATUS_DONE_TAG)
  end

end
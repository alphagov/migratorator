class RootController < ApplicationController

  # there's no magic here

  def index
    # load index.html.erb
    @revisions = HistoryTracker.limit(15).all

    @overall_progress = Mapping.progress([], Tag::STATUS_DONE_TAG)
    @friendly_url_progress = Mapping.progress(["source:aliases"], Tag::STATUS_DONE_TAG)
    @mapping_exercise_progress = Mapping.progress(["source:mapping-exercise"], Tag::STATUS_DONE_TAG)
  end

end
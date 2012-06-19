class RootController < ApplicationController

  # there's no magic here

  def index
    # load index.html.erb
    @revisions = HistoryTracker.limit(15).all

    @overall_progress = Mapping.progress(Mapping, Tag::STATUS_DONE_TAG)
    @friendly_url_progress = progress_for_tags(["source:aliases"])
    @mapping_exercise_progress = progress_for_tags(["source:mapping-exercise"])
    @crawler_progress = progress_for_tags(["source:crawler"])
    @apache_logs_progress = progress_for_tags(["source:apache-logs"])
  end

  private
    def progress_for_tags(tags_array)
      Mapping.progress(Mapping.tagged_with_all(tags_array), Tag::STATUS_DONE_TAG)
    end

end
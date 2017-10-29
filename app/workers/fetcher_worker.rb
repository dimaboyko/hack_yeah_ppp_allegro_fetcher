class FetcherWorker
  include Sidekiq::Worker

  def perform
    ::External::Allegro::Fetcher.perform
  end
end

class TestWorker
  include Sidekiq::Worker

  def perform
    puts "Job done."
  end
end

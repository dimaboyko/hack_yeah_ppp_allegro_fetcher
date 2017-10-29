module External
  module Allegro
    class Fetcher
      extend ::Concerns::Performable

      PROVIDER = 'allegro.pl'
      BATCH_SIZE = 100

      def perform
        auctions = allegro_client.fetch_data
        return if auctions.nil?

        auctions.in_groups_of(BATCH_SIZE, false) do |group|
          group.each do |auction|
            AdapterWorker.perform_async(auction)
          end
        end
      end
    end
  end
end

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
            auction_data = ::Scarpers::Auction.perform(auction['itemId'])
            auctioneer_data = ::Scarpers::Auctioneer.perform(auction_data[:auctioneer_id])
            krs_data = ::Scarpers::Krs.perform(auctioneer_data['company_nip'])

            hack_yeah_app_client.create_auction(
              {
                auctioneer_id: auction_data[:auctioneer_id],
                auction_id: auction['itemId'],
                auctioneer_data: auctioneer_data.merge(krs_data),
                auction_data: auction_data[:auction_data],
                auction_provider: PROVIDER
              }
            )
          end
        end
      end

      private

      def allegro_client
        @allegro_client ||= ::External::Allegro::Client.instance
      end

      def hack_yeah_app_client
        @hack_yeah_app_client ||= ::External::HackYeahApp::Client.instance
      end
    end
  end
end

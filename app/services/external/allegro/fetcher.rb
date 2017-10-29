module External
  module Allegro
    class Fetcher
      extend ::Concerns::Performable

      PROVIDER = 'allegro.pl'

      def perform
        auctions = allegro_client.fetch_data
        return if auctions.nil?

        auctions.each do |auction_data|
          auctioneer_data = ::Scarpers::Auctioneer.perform(auction_data['userId'])
          auction_data = ::Scarpers::Auction.perform(auction_data['itemId'])

          hack_yeah_app_client.create_auction(
            {
              auctioneer_id: auction_data['userId'],
              auction_id: auction_data['itemId'],
              auctioneer_data: auctioneer_data,
              auction_data: auction_data,
              auction_provider: PROVIDER
            }
          )
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

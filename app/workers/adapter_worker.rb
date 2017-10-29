class AdapterWorker
  include Sidekiq::Worker

  PROVIDER = 'allegro.pl'

  def perform(auction)
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

  private

  def hack_yeah_app_client
    @hack_yeah_app_client ||= ::External::HackYeahApp::Client.instance
  end
end

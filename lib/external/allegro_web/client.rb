module External
  module AllegroWeb
    class RequestFailed < StandardError; end
    class TimeoutConnectionError < StandardError; end

    class Client
      include Singleton

      PROVIDER_URL = 'http://allegro.pl'

      def fetch_auctioneer_data(auctioneer_id)
        get("sellerInfoFrontend/#{auctioneer_id}/aboutSeller")
      end

      def fetch_auction_data(auction_id)
        get("show_item.php?item=#{auction_id}")
      end

      private

      def get(path)
        request(:get, path)
      rescue ::Excon::Errors::SocketError
        nil
      end

      def request(method, path, query: {}, body: "")
        response = connection.request(
          method: method, path: path, query: query, body: body
        ).tap { |resp|
          raise RequestFailed.new(
            "status: #{resp.status}, path: #{path}, query: #{query}, body: #{body}"
          ) unless [200, 201].include?(resp.status)
        }

        Nokogiri::HTML(response.body)
      rescue ::Excon::Errors::Timeout
        raise TimeoutConnectionError.new
      end

      def connection
        Excon.new(PROVIDER_URL)
      end
    end
  end
end

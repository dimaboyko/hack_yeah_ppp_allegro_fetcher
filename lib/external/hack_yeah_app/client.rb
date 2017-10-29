module External
  module HackYeahApp
    class RequestFailed < StandardError; end
    class TimeoutConnectionError < StandardError; end

    class Client
      include Singleton

      APPLICATION_URL = 'http://localhost:3000'

      def create_auction(auction_params)
        post('api/v1/auctions', auction_params)
      end

      private

      def post(path, hash_data)
        request(:post, path, body: hash_data.to_json)
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

        JSON.parse(response.body)
      rescue ::Excon::Errors::Timeout
        raise TimeoutConnectionError.new
      end

      def connection
        Excon.new(APPLICATION_URL, headers: headers)
      end

      def headers
        {
          "Content-Type" => "application/json",
          "x-hack-yeah-api-key" => ::A9n.api_key
        }
      end
    end
  end
end

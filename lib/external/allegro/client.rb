module External
  module Allegro
    class RequestFailed < StandardError; end
    class TimeoutConnectionError < StandardError; end

    class Client
      include Singleton

      FETCHER_URL = 'https://fa8be8b5.ngrok.io/get_items'

      def fetch_data
        response = ::Excon.get(FETCHER_URL)
        JSON.parse(response.body)
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

        JSON.parse(response.body)
      rescue ::Excon::Errors::Timeout
        raise TimeoutConnectionError.new
      end

      def connection
        Excon.new(FETCHER_URL, headers: headers)
      end
    end
  end
end

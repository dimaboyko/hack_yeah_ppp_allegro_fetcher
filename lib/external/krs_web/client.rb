module External
  module KrsWeb
    class RequestFailed < StandardError; end
    class TimeoutConnectionError < StandardError; end

    class Client
      include Singleton

      PROVIDER_URL = 'http://www.krs-online.com.pl/'

      def search_nip(nip)
        get("?p=6&look=#{nip}")
      end

      def fetch(url)
        get(url)
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

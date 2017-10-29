module Scarpers
  class Auction
    extend ::Concerns::Performable

    def initialize(auction_id)
      @auction_id = auction_id
    end

    def perform
      return {} if auction_id.nil?

      parameters_section = document_data.at_css('.attributes-container')

      return {} if parameters_section.nil?

      parameters_groups = parameters_section.css('ul.offer-attributes')

      parameters_data = Hash.new

      parameters_groups.each do |group|
        unless group.children.nil?
          group.children.css('li').each do |item|
            parameters_data[
              sanitizer_html_from(item.at_css('.attribute-name')).to_sym
            ] = sanitizer_html_from(item.at_css('.attribute-value'))
          end
        end
      end

      # tytul

      # -> opis -> nice to have

      # czy to kup teraz -> sprawdz na innej aukcji

      # sciezka kategorii w postaci tablicy

      # dane firmy

      # nick allegro

      # czy jest firmą? true / false

      # liczba opini o koncie

      parameters_data
    end

    private

    attr_reader :auction_id

    def document_data
      @document_data ||= client.fetch_auction_data(auction_id)
    end

    def sanitizer_html_from(data)
      ActionView::Base.full_sanitizer.sanitize(data.to_s).gsub(/[^0-9a-zA-Z]/, '')
    end

    def client
      @client ||= ::External::AllegroWeb::Client.instance
    end
  end
end

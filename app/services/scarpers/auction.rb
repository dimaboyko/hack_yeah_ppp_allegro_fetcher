module Scarpers
  class Auction
    extend ::Concerns::Performable

    def initialize(auction_id)
      @auction_id = auction_id
    end

    def perform
      return {} if auction_id.nil?

      auctioneer_id = nil
      parameters_data = Hash.new

      document_data.xpath("//a").each do |link|
        if link && link.attributes
          value = link.attributes["href"].try(:value)
          matched_value = String(value.to_s.match(/uzytkownik\/[\d]+\/oceny/)).presence
          auctioneer_id = matched_value.gsub(/\D/, '') if matched_value.present?
        end
      end

      parameters_section = document_data.at_css('.attributes-container')

      return {} if parameters_section.nil?

      parameters_groups = parameters_section.css('ul.offer-attributes')
      parameters_groups.each do |group|
        unless group.children.nil?
          group.children.css('li').each do |item|
            parameters_data[
              sanitizer_html_from(item.at_css('.attribute-name')).to_sym
            ] = sanitizer_html_from(item.at_css('.attribute-value'))
          end
        end
      end

      parameters_data[:title] = document_data.at_css('h1.title').try(:children).first

      parameters_data[:description] = document_data.at_css('#description').to_s

      # sciezka kategorii w postaci tablicy
      # parameters_data[:category_tree] = document_data.at_css('ol#breadcrumbs-list').map(&:children).map(&:to_s)

      # liczba opini o koncie

      {
        auctioneer_id: auctioneer_id,
        auction_data: parameters_data
      }
    end

    private

    attr_reader :auction_id

    def document_data
      @document_data ||= client.fetch_auction_data(auction_id)
    end

    def sanitizer_html_from(data)
      ActionView::Base.full_sanitizer.sanitize(data.to_s.strip)
    end

    def client
      @client ||= ::External::AllegroWeb::Client.instance
    end
  end
end

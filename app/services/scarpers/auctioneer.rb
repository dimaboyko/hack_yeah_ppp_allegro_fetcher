module Scarpers
  class Auctioneer
    extend ::Concerns::Performable

    def initialize(auctioneer_id)
      @auctioneer_id = auctioneer_id
    end

    def perform
      return {} if auctioneer_id.nil?

      document_data = client.fetch_auctioneer_data(auctioneer_id)
      auctioneer_company_data = document_data.at_css('#sellerUserData')
      auctioneer_contact_data = document_data.at_css('#sellerInfoContactInfo')

      return {} if auctioneer_company_data.nil? || auctioneer_contact_data.nil?

      {}.tap { |hash_data|
        hash_data.merge!(company_data_from(auctioneer_company_data))
        hash_data.merge!(contact_data_from(auctioneer_contact_data))
      }
    end

    private

    attr_reader :auctioneer_id

    def company_data_from(auctioneer_company_data)
      {
        company_name: sanitizer_html_from(
          auctioneer_company_data.at_css('div.seller-user-cname').try(:children)
        ),
        company_city: sanitizer_html_from(
          auctioneer_company_data.at_css('div.seller-user-city').try(:children)
        ),
        company_street: sanitizer_html_from(
          auctioneer_company_data.at_css('div.seller-user-street').try(:children)
        ),
        company_nip: sanitizer_html_from(
          auctioneer_company_data.at_css('div.seller-user-nip').try(:children)
        ),
        company_regon: sanitizer_html_from(
          auctioneer_company_data.at_css('div.seller-user-regon').try(:children)
        ),
        company_krs: sanitizer_html_from(
          auctioneer_company_data.at_css('div.seller-user-krs').try(:children)
        )
      }
    end

    def contact_data_from(auctioneer_contact_data)
      {
        phones: collect_items_for(auctioneer_contact_data.css('a[href^="tel"]')),
        emails: collect_items_for(auctioneer_contact_data.css('a[href^="mailto"]'))
      }
    end

    def collect_items_for(data)
      data.map(&:children).map(&:to_s).compact.uniq
    end

    def sanitizer_html_from(data)
      ActionView::Base.full_sanitizer.sanitize(data.to_s)
    end

    def client
      @client ||= ::External::AllegroWeb::Client.instance
    end
  end
end

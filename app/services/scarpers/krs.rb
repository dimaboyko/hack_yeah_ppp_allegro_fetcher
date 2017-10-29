module Scarpers
  class Krs
    extend ::Concerns::Performable

    def initialize(nip)
      @nip = nip
    end

    def perform
      return {} if clean_nip.nil? || krs_company_url.blank?

      {
        founded_at: formatted_foundation_date
      }
    end

    private
    attr_reader :nip

    def clean_nip
      @clean_nip ||= nip.to_s.gsub(/[^0-9]/, '')
    end

    def formatted_foundation_date
      date = detect_foundation_date
      date.split('-').one? ? Date.new(date.to_i).to_s : date
    rescue
      nil
    end

    def detect_foundation_date
      var1 = company_html.css('table.tab1 tr th:contains("Data powstania")').first
      var2 = company_html.css('table.tab1 tr th:contains("Data rozpoczęcia działalności")').first

      (var1 || var2).parent.children.css('td').first.children.to_s
    end

    def company_html
      @company_html ||= client.fetch(krs_company_url)
    end

    def krs_company_url
      @krs_company_url ||= (client.search_nip(clean_nip).css('#main a').first || {})["href"]
    end

    def client
      @client ||= ::External::KrsWeb::Client.instance
    end
  end
end

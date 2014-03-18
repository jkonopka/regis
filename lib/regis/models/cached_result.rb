module Regis

  class CachedResult < ActiveRecord::Base

    serialize :result, JSON
    serialize :query, JSON

    before_save :ensure_key

    def self.with_cache(provider, query, &block)
      cached = find_by_query(provider, query)
      if cached
        result = cached.result
      else
        result = yield
        CachedResult.create!(
          provider: provider.name,
          query: query,
          result: result)
      end
      result
    end

    def self.find_by_query(provider, query)
      if query
        key = generate_key(query)
        where(provider: provider.name, key: key).first
      end
    end

    private

      def self.generate_key(query)
        Base64.encode64(Digest::SHA256.digest(query.to_json)).gsub(/[\s=]$/, '')
      end

      def ensure_key
        self.key ||= self.class.generate_key(self.query)
        nil
      end

  end

end

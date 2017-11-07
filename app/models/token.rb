class Token
  class << self
    def encode(payload)
      JWT.encode payload, secret, 'HS256'
    end

    def decode(token)
      body = JWT.decode(token, secret, true, { :algorithm => 'HS256' }).first
      HashWithIndifferentAccess.new body
    rescue
      nil
    end

    private
      def secret
        Rails.application.secrets.secret_key_base
      end
  end
end

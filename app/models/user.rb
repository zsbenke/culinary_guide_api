class User < ApplicationRecord
  validates :unique_hash, uniqueness: true

  def self.authenticate(token, options = {})
    payload = Token.decode(token)
    return if payload.nil? || payload.try(:[], 'unique_hash').nil?
    find_or_create_by(unique_hash: payload['unique_hash'])
  end
end

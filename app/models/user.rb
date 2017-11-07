class User < ApplicationRecord
  validates :unique_hash, uniqueness: true

  def self.authenticate(token, options = {})
    payload = Token.decode(token)
    return if payload.try(:[], 'unique_hash').nil?
    find_or_create_by(unique_hash: payload['unique_hash'])
  end

  def subscriber?
    return false if expires_at.nil?
    expires_at > Time.now
  end

  def as_json(options)
    { unique_hash: unique_hash, expires_at: expires_at, subscriber: subscriber? }
  end
end

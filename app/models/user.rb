class User < ApplicationRecord
  validates :unique_hash, uniqueness: true
end

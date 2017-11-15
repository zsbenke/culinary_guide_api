module Filterable
  extend ActiveSupport::Concern

  included do
    include PgSearch

    pg_search_scope :search, against: :search_cache,
      using: {
        tsearch: {
          tsvector_column: 'tsv'
        }
      }
  end
end

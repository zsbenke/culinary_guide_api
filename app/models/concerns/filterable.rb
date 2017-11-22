module Filterable
  extend ActiveSupport::Concern

  included do
    include PgSearch

    pg_search_scope :by_keyword, against: :search_cache,
      using: {
        tsearch: {
          tsvector_column: 'tsv'
        }
      }

    scope :search, -> (keyword) { by_keyword(keyword) if keyword.present? }
  end
end

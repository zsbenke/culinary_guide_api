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
    scope :filter, -> (tokens) {
      if tokens
        columns = columns_hash
        table = arel_table
        query = unscoped
        tokens_hash = {}

        tokens.each do |token|
          column = token['column']
          tokens_hash["#{column}"] ||= []
          tokens_hash["#{column}"] << token
        end

        tokens_hash.each do |column, tokens|
          token_values = tokens.map { |t| t['value'] }
          token_values << [nil, ''] if token_values.include?(nil) || token_values.include?('')
          token_values.uniq!
          token_values.flatten!

          if columns[column].present?
            query = if columns[column].array? && columns[column].type == :integer
                      query.where("#{connection.quote_column_name(column)} @> ARRAY[?]::integer[]", token_values)
                    elsif columns[column].array?
                      query.where("#{connection.quote_column_name(column)} @> ARRAY[?]::varchar[]", token_values)
                    else
                      query.where(table[column].in(token_values))
                    end
          end

          query = query.search(token_values) if column == 'search'
        end

        query
      end
    }

  end
end

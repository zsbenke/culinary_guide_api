module Taggable
  extend ActiveSupport::Concern

  included do
    def tags_array
      return [] unless tags_index.present?
      tags_index.split(',').map(&:strip)
    end

    def tags
      Tag.where(name: tags_array)
    end
  end
end

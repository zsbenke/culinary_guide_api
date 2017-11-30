class Tag < ApplicationRecord
  def name_columns
    self.class.columns_hash.keys.select { |c| c.include?('name') }
  end
end

class LocalizedString < ActiveRecord::Base
  validates :column, presence: true
  validates :value, uniqueness: { scope: [:model, :column] }, presence: true

  def model_column
    "#{model}-#{column}"
  end

  def localized?
    Rails.configuration.available_locales.each do |locale|
      return false if self.try("value_in_#{locale}").blank?
    end

    return true
  end

  def records
    model_class = model.classify.constantize
    model_class.where("#{column}" => value)
  end

  def records_count
    records.count
  end
end


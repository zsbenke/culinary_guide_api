module Openable
  extend ActiveSupport::Concern

  included do
    def open_times_label(day_name, locale: :hu)
      day_name_index = I18n.t('date.day_names', locale: :en).map(&:downcase).index(day_name.to_s)
      day_name = I18n.t('date.abbr_day_names', locale: :en).map(&:downcase)[day_name_index]
      label = ""
      rows = [
        (self.send("open_#{day_name}_morning_start") || '--'),
        (self.send("open_#{day_name}_morning_end") || '--'),
        (self.send("open_#{day_name}_afternoon_start") || '--'),
        (self.send("open_#{day_name}_afternoon_end") || '--')
      ]

      closed_label = I18n.t('restaurant.values.open_times', locale: locale)['Zárva'.to_sym]
      closed_label_in_hu = I18n.t('restaurant.values.open_times', locale: :hu)['Zárva'.to_sym]
      return closed_label if rows[0] == closed_label_in_hu || rows[1] == closed_label_in_hu || rows[2] == closed_label_in_hu || rows[3] == closed_label_in_hu
      return nil if rows[0] == '--' || rows[1] == '--'

      open_times = I18n.t('restaurant.values.open_times', locale: locale)
      label = "#{open_times[rows[0].to_sym]}-#{open_times[rows[1].to_sym]}"
      label += " #{open_times[rows[2].to_sym]}-#{open_times[rows[3].to_sym]}" if rows[2] != '--' && rows[3] != '--'
      return label
    end

    def open_results(locale: :hu)
      index = 0
      current_start, current_label = nil
      full_label = []
      day_names_label = ->(starting, ending) {
        days = I18n.t('date.abbr_day_names', locale: locale).dup.rotate(1)
        starting == ending ? days[starting] : "#{days[starting]}-#{days[ending]}"
      }

      days = I18n.t('date.day_names', locale: :en).dup.rotate(1).map { |dn| dn.downcase.to_sym }
      days.each_with_index do |day, i|
        index = i
        label = self.open_times_label(day, locale: locale)
        if label != current_label
          full_label << "#{day_names_label.call(current_start, index - 1)}: #{current_label}" if current_label.present?
          current_label = label
          current_start = index
        end
      end

      full_label << "#{day_names_label.call(current_start, index)}: #{current_label}" if current_label.present?
      full_label = full_label.join(', ')
      full_label << " (#{open_info})" if try(:open_info).present? && locale == :hu
      full_label
    end
    alias_method :open_results_as_formatted, :open_results
  end
end

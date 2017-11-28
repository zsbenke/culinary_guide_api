module Openable
  extend ActiveSupport::Concern

  included do
    before_save :cache_open_day_names

    scope :open_at, -> (date) {
      return unless date.present?

      begin
        date = Time.parse(date)
      rescue
        return none
      end

      to_time = -> (time) { "to_timestamp(#{time}, 'HH24:MI')::time" }
      time = date.strftime('%H:%M')
      long_day_name  = date.strftime("%A").downcase
      day_name       = date.strftime("%a").downcase

      open_on_morning   = where("open_on_#{long_day_name}" => true).
                          where.not(
                            "open_#{day_name}_morning_start" => ['--', 'Zárva'],
                            "open_#{day_name}_morning_end" => ['--', 'Zárva']
                          )
      open_on_afternoon = where("open_on_#{long_day_name}" => true).
                          where.not(
                            "open_#{day_name}_afternoon_start" => ['--', 'Zárva'],
                            "open_#{day_name}_afternoon_end" => ['--', 'Zárva']
                          )
      open_on_morning = open_on_morning.where(
        "#{to_time.call('?')} BETWEEN "\
        "#{to_time.call("open_#{day_name}_morning_start")} AND "\
        "#{to_time.call("open_#{day_name}_morning_end")}", "#{time}"
      )
      open_on_afternoon = open_on_afternoon.where(
        "#{to_time.call('?')} BETWEEN "\
        "#{to_time.call("open_#{day_name}_afternoon_start")} AND "\
        "#{to_time.call("open_#{day_name}_afternoon_end")}", "#{time}"
      )
      where(id: open_on_morning.pluck(:id) + open_on_afternoon.pluck(:id))
    }

    def open_at?(date)
      self.class.open_at(date).pluck(:id).include? id
    end

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

    private
      def cache_open_day_names
        I18n.t('date.day_names', locale: :en).map(&:downcase).each do |day_name|
          next unless self.respond_to?("open_on_#{day_name}")
          closed_label_in_hu = I18n.t('restaurant.values.open_times', locale: :hu)[:Zárva]
          open_value = open_times_label(day_name).present? && open_times_label(day_name) != closed_label_in_hu
          self.send("open_on_#{day_name}=", open_value)
        end
      end
  end
end

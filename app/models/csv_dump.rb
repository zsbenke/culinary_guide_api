require 'csv'

class CSVDump

  class << self
    def all(options = {})
      entries = Dir.entries(csv_dumps_path).select { |f| f.match /#{csv_dump_name}/ }.map { |f| find(f) }
      entries = entries.select { |i| i.imported == options[:imported] } unless options[:imported].nil?
      entries.sort_by(&:created_at).reverse
    end

    def imported
      all(imported: true)
    end

    def non_imported
      all(imported: false)
    end

    def csv_dumps_path
      if Rails.configuration.respond_to?(:csv_dumps_path)
        Rails.configuration.csv_dumps_path.to_s
      else
        File.expand_path('~/csv_dumps/')
      end
    end

    def find(basename)
      file = File.new("#{csv_dumps_path}/#{basename}", 'r')
      file_stat = File::Stat.new file.path
      new(
        name: File.basename(file.path),
        path: file.path,
        size: file_stat.size,
        created_at: file_stat.ctime
      )
    end

    def csv_dump_name
      'csv_dump'
    end

    def table_map
      { 'restaurant_test' => 'restaurant_review' }
    end
  end

  attr_accessor :name, :path, :size, :created_at
  attr_reader :imported, :data, :headers

  def initialize(options = {})
    @name = options[:name]
    @path = options[:path]
    @size = options[:size]
    @created_at = options[:created_at]
    @imported = (Xattr.new(@path)['user.gm_imported'] == 'true')
  end

  def imported?
    @imported == true
  end

  def read
    @data = []

    if @name.match /\.csv\.gz/
      Zlib::GzipReader.open(@path) do |gzip|
        csv = CSV.new gzip
        csv.each { |row| @data << row }
      end
    else
      @data = CSV.open(@path).read
    end

    @headers = @data[0]
    @data.shift(1)
  end

  def import(remove_existing: true, generate_log: true)
    model_name = name.split("_#{self.class.csv_dump_name}")[0].singularize
    model_name_mapped = self.class.table_map.try(:[], model_name)
    model_name = model_name_mapped if model_name_mapped.present?
    model_class = model_name.classify.constantize

    read

    # remove existing records
    if remove_existing == true
      index_of_id = @headers.index('id')
      raise MissingIDColumnError if index_of_id.nil?
      max_id = @data.map { |r| r[index_of_id].to_i }.max + 1

      model_class.delete_all
      model_class.connection.execute("ALTER SEQUENCE #{model_name.pluralize}_id_seq RESTART WITH #{max_id}")
    end

    @data.each do |entry|
      record = model_class.new

      @headers.each do |column|
        next if remove_existing == false && column == 'id'
        value = entry[@headers.index(column)]
        record.send("#{column}=", value) if record.respond_to?("#{column}=")
      end

      begin
        record.save
      rescue ActiveRecord::InvalidForeignKey
        log "couldn't import record #{model_name} ##{record.id}: InvalidForeignKey" if generate_log
        next
      end

      log "imported record #{model_name} ##{record.id}" if generate_log
    end

    @imported = true
    Xattr.new(@path)['user.gm_imported'] = imported

    self
  end

  def stale?
    created_at < 14.days.ago
  end

  def created?
    created_at.present?
  end

  def destroy
    File.delete(path)
  end

  private

    def log(msg)
      msg = "CSV Dump import - #{Time.now}: #{msg}"
      puts msg
      Rails.logger.info msg
    end
end

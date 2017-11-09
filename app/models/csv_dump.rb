require 'csv'

class CSVDump

  class << self
    def all(options = {})
      entries = Dir.entries(csv_dumps_path).select { |f| f.match /#{csv_dump_name}/ }.map { |f| find(f) }
      entries = entries.select { |i| i.imported == options[:imported] } unless options[:imported].nil?
      entries.sort_by(&:created_at).reverse
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
    @imported = (Xattr.new(@path)['gm_imported'] == 'true')

    # read data from gzip file
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

  def imported?
    @imported == true
  end

  def import
    model_name = name.split("_#{self.class.csv_dump_name}")[0].singularize
    model_name_mapped = self.class.table_map.try(:[], model_name)
    model_name = model_name_mapped if model_name_mapped.present?
    model_class = model_name.classify.constantize

    # remove existing records
    model_class.delete_all
    model_class.connection.execute("ALTER SEQUENCE #{model_name.pluralize}_id_seq RESTART WITH 1")

    @data.each do |entry|
      record = model_class.new

      @headers.each do |column|
        value = entry[@headers.index(column)]
        record.send("#{column}=", value) if record.respond_to?("#{column}=")
      end

      record.save

      log "imported record #{model_name} ##{record.id}"
    end

    @imported = true
    Xattr.new(@path)['gm_imported'] = imported

    self
  end

  private

    def log(msg)
      msg = "CSV Dump import - #{Time.now}: #{msg}"
      puts msg
      Rails.logger.info msg
    end
end

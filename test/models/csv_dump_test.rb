require 'test_helper'

class CSVDumpTest < ActiveSupport::TestCase
  def setup
    csv_dump = CSVDump.find('restaurants_csv_dump.csv.gz')
    Xattr.new(csv_dump.path)['gm_imported'] = 'false'

    csv_dump = CSVDump.find('restaurants_csv_dump.csv')
    Xattr.new(csv_dump.path)['gm_imported'] = 'false'

    csv_dump = CSVDump.find('restaurant_tests_csv_dump.csv.gz')
    Xattr.new(csv_dump.path)['gm_imported'] = 'true'
  end

  test "should return the path of csv dumps directory" do
    csv_dumps_path = CSVDump.csv_dumps_path

    assert_equal Rails.configuration.csv_dumps_path.to_s, csv_dumps_path
  end

  test "should list all available csv dumps" do
    csv_dumps = CSVDump.all
    filenames = [
      'restaurant_tests_csv_dump.csv.gz',
      'restaurants_csv_dump.csv.gz',
      'restaurants_csv_dump.csv'
    ]

    assert_equal 3, csv_dumps.count

    csv_dumps.each do |csv_dump|
      assert filenames.include? csv_dump.name
      assert csv_dump.size > 0
      assert csv_dump.path.include? CSVDump.csv_dumps_path
    end
  end

  test "should list imported and non-imported csv dumps" do
    imported_csv_dumps = CSVDump.all(imported: true)
    non_imported_csv_dumps = CSVDump.all(imported: false)
    assert_equal 1, imported_csv_dumps.count
    assert_equal 2, non_imported_csv_dumps.count

    imported_csv_dumps.each     { |csvd| assert     csvd.imported? }
    non_imported_csv_dumps.each { |csvd| assert_not csvd.imported? }
  end

  test "should parse csv as plain and gzipped" do
    csv_dump = CSVDump.find('restaurants_csv_dump.csv')
    csv_dump.read
    assert_equal 115, csv_dump.headers.count
    assert_equal 8, csv_dump.data.count

    csv_dump = CSVDump.find('restaurants_csv_dump.csv.gz')
    csv_dump.read
    assert_equal 115, csv_dump.headers.count
    assert_equal 8, csv_dump.data.count
  end

  test "should import records from csv dump" do
    csv_dump = CSVDump.find('restaurants_csv_dump.csv.gz')
    csv_dump.import

    assert_equal csv_dump.data.count, Restaurant.count
    assert csv_dump.imported?
  end

  test "should import records remapped to new tablename" do
    csv_dump = CSVDump.find('restaurant_tests_csv_dump.csv.gz')
    csv_dump.import

    assert_equal csv_dump.data.count, RestaurantReview.count
    assert csv_dump.imported?
  end

  def teardown
    csv_dump = CSVDump.find('restaurants_csv_dump.csv.gz')
    Xattr.new(csv_dump.path)['gm_imported'] = 'false'
  end
end

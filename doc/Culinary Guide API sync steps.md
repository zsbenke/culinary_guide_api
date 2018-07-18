# GMDB Export

1. Lokalizált stringek
```ruby
CSVDump.create(:localized_strings)
```
2. Címkék
```ruby
CSVDump.create(ActsAsTaggableOn::Tag)
# az output file neve ActsAsTaggableOn::Tag.csv.gz lesz, ezt át kell nevezni tags.csv.gz-re
```
3. Éttermek
```ruby
ids = Restaurant.by_year('2018').by_status('Lezárt anyag').pluck(:id)
CSVDump.create(:restaurants, id: ids)
```
4. Étterem tesztek
```ruby
ids = RestaurantTest.by_year('2018').by_status('Lezárt anyag').pluck(:id)
CSVDump.create(:restaurant_tests, id: ids)
```
5. Étterem képek
```ruby
image_ids = Restaurant.by_year('2018').by_status('Lezárt anyag').pluck(:hero_image_id)
CSVDump.create(:restaurant_images, id: image_ids)
```

# CulinaryGuideAPI Import

1. Lokalizált stringek
```ruby
CSVDump.find('localized_strings.csv.dz')
```
2. Címkék
```ruby
CSVDump.find('tags.csv.gz').import
```
3. Éttermek
```ruby
CSVDump.find('restaurants.csv.gz').import
```
4. Étterem review-k
```ruby
CSVDump.find('restaurant_tests.csv.gz').import
```
5. Étterem fotók
```ruby
CSVDump.find('restaurant_images.csv.gz').import
```
6. Hero image beállítása
```ruby
RestaurantImage.all.each(&:set_as_hero_image)
```
7. Facet generálás 
```ruby
Face.generate(:restaurants)
```

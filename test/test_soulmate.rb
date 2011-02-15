require 'helper'

class TestSoulmate < Test::Unit::TestCase
  def test_integration_can_load_values_and_query
    items = []
    venues = File.open(File.expand_path(File.dirname(__FILE__)) + '/samples/venues.json', "r")
    venues.each_line do |venue|
      items << JSON.parse(venue)
    end
    
    items_loaded = Soulmate::Loader.new('venues').load(items)
    
    assert_equal 5, items_loaded
    
    matcher = Soulmate::Matcher.new('venues')
    results = matcher.matches_for_term('stad', :limit => 5)
    
    assert_equal 3, results.size
    assert_equal 'Angel Stadium', results[0]['term']
  end
end

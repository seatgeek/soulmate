require 'helper'

class TestSoulmate < Test::Unit::TestCase
  def test_integration_can_load_values_and_query
    items = []
    venues = File.open(File.expand_path(File.dirname(__FILE__)) + '/samples/venues.json', "r")
    venues.each_line do |venue|
      items << JSON.parse(venue)
    end
    
    items_loaded = Soulmate::Loader.new('venues').load(items)
    
    assert_equal 6, items_loaded
    
    matcher = Soulmate::Matcher.new('venues')
    results = matcher.matches_for_term('stad', :limit => 5)
    
    assert_equal 5, results.size
    assert_equal 'Citi Field', results[0]['term']
  end
  
  def test_integration_can_load_values_and_query_via_aliases
    items = []
    venues = File.open(File.expand_path(File.dirname(__FILE__)) + '/samples/venues.json', "r")
    venues.each_line do |venue|
      items << JSON.parse(venue)
    end
    
    items_loaded = Soulmate::Loader.new('venues').load(items)
    
    assert_equal 6, items_loaded
    
    matcher = Soulmate::Matcher.new('venues')
    results = matcher.matches_for_term('land shark stadium', :limit => 5)
    
    assert_equal 1, results.size
    assert_equal 'Sun Life Stadium', results[0]['term']
    
    # Make sure we don't get dupes between aliases and the original term
    # this shouldn't happen due to Redis doing an intersect, but just in case!
    
    results = matcher.matches_for_term('stadium', :limit => 5)    
    assert_equal 5, results.size
  end
end

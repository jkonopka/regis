# Regis

Regis provides an API to perform geocoding. It wraps providers such as Google behind a consistent interface.

how to change providers:  Regis.configure(:provider => :google) (default :google, select from :google,:ovi,:here,:test - FYI: don't choose :test)

how to change timeout:  Regis.configure(:timeout => 10)  (default 3)


pebblebed = ::Pebblebed::Connector.new(GROVEKEY, {})

regis = pebblebed.regis
regis.post("/geocode", {:address => "44 Blah Blah St. 01010", :config => {:normalize => "true", :provider => "ovi", :region => "us"}})

config isn't preserved between posts...

v1.1
:provider => ["google","ovi","here"]

example results:

Regis.configure(:normalize => true)
 => {:timeout=>3, :provider=>:google, :ip_provider=>:freegeoip, :language=>:en, :http_headers=>{}, :use_https=>false, :http_proxy=>nil, :https_proxy=>nil, :api_key=>nil, :cache=>nil, :cache_prefix=>"regis:", :app_id=>"6BfYFgVfbRGLufNa3YyH", :app_code=>"dT4mkeydz7V0oVQ01PDHQQ", :normalize=>true, :always_raise=>[], :units=>:mi, :distances=>:linear}

Regis.search("Looking Glass Road Meadow Village #1 Lot 58, Big Sky MT", {:region => "us"})
 => #<Regis::Result::Google:0x007fd3e48fc900 @data=[{"location"=>{"lat"=>45.271159, "lng"=>-111.2990514, "location_type"=>"APPROXIMATE", "result_type"=>"locality", "accuracy"=>false, "confidence"=>0.4}, "address"=>{"formatted_address"=>"Big Sky, MT, USA", "country"=>"US", "state"=>"MT", "county"=>"Gallatin County", "city"=>"Big Sky", "street"=>"", "house_number"=>nil, "postal_code"=>nil}}], @cache_hit=nil, @rate_limited=false>

Regis.search("3 Paulmier Place Jersey City NJ 07302", {:region => "us"})
 => #Regis::Result::Google:0x007fd3e6c4d800 @data=[{"location"=>{"lat"=>40.71906600000001, "lng"=>-74.0459939, "location_type"=>"ROOFTOP", "result_type"=>"street_address", "accuracy"=>true, "confidence"=>1.0}, "address"=>{"formatted_address"=>"3 Paulmier Place, Jersey City, NJ 07302, USA", "country"=>"US", "state"=>"NJ", "county"=>"Hudson County", "city"=>"Jersey City", "street"=>"3 Paulmier Place", "house_number"=>"3", "postal_code"=>"07302"}}], @cache_hit=nil, @rate_limited=false>


      when "ROOFTOP"
        1.0
      when "APPROXIMATE"
        0.8
      when "RANGE_INTERPOLATED"
        0.7
      when "GEOMETRIC_CENTER"


### normalized results
location_type :
  rooftop approximate range_interpolated geometric_center

result_type :
  street_address route intersection political country administrative_area_level_1
  administrative_area_level_2 administrative_area_level_3 colloquial_area locality
  sublocality neighborhood premise subpremise postal_code natural_feature airport
  park point_of_interest

accuracy :
  true or false


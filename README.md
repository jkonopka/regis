# Regis

Regis provides an API to perform geocoding. It wraps providers such as Google behind a consistent interface.

how to change providers:  Regis.configure(:provider => :google) (default :google, select from :google,:ovi,:here,:test - FYI: don't choose :test)

how to change timeout:  Regis.configure(:timeout => 10)  (default 3)


pebblebed = ::Pebblebed::Connector.new(GROVEKEY, {})

regis = pebblebed.regis
regis.post("/geocode", {:address => "44 Blah Blah St. 01010", :config => {:normalize => "true", :provider => "ovi"}})

config isn't preserved between posts...

v1.1
:provider => ["google","ovi","here"]

example results:
1.9.3-p545 :001 > Regis.search("3 paulmier place 07302")

 => #<Regis::Result::Google:0x007f82cc17c040 @data=[{"address_components"=>[{"long_name"=>"3", "short_name"=>"3", "types"=>["street_number"]}, {"long_name"=>"Paulmier Place", "short_name"=>"Paulmier Pl", "types"=>["route"]}, {"long_name"=>"Van Vorst Park", "short_name"=>"Van Vorst Park", "types"=>["neighborhood", "political"]}, {"long_name"=>"Jersey City", "short_name"=>"Jersey City", "types"=>["locality", "political"]}, {"long_name"=>"Hudson County", "short_name"=>"Hudson County", "types"=>["administrative_area_level_2", "political"]}, {"long_name"=>"New Jersey", "short_name"=>"NJ", "types"=>["administrative_area_level_1", "political"]}, {"long_name"=>"United States", "short_name"=>"US", "types"=>["country", "political"]}, {"long_name"=>"07302", "short_name"=>"07302", "types"=>["postal_code"]}], "formatted_address"=>"3 Paulmier Place, Jersey City, NJ 07302, USA", "geometry"=>{"location"=>{"lat"=>40.71906600000001, "lng"=>-74.0459939}, "location_type"=>"ROOFTOP", "viewport"=>{"northeast"=>{"lat"=>40.72041498029151, "lng"=>-74.04464491970849}, "southwest"=>{"lat"=>40.71771701970851, "lng"=>-74.04734288029151}}}, "types"=>["street_address"]}], @cache_hit=nil, @rate_limited=false>

1.9.3-p545 :002 > Regis.configure(:normalize => true)
 => {:timeout=>3, :provider=>:google, :ip_provider=>:freegeoip, :language=>:en, :http_headers=>{}, :use_https=>false, :http_proxy=>nil, :https_proxy=>nil, :api_key=>nil, :cache=>nil, :cache_prefix=>"regis:", :app_id=>"6BfYFgVfbRGLufNa3YyH", :app_code=>"dT4mkeydz7V0oVQ01PDHQQ", :normalize=>true, :always_raise=>[], :units=>:mi, :distances=>:linear}

1.9.3-p545 :003 > Regis.search("3 paulmier place 07302")
 => #<Regis::Result::Google:0x007f82cbef9b60 @data=[{"location"=>{"lat"=>40.71906600000001, "lng"=>-74.0459939, "location_type"=>1.0, "confidence"=>1.0}, "address"=>{"formatted_address"=>"3 Paulmier Place, Jersey City, NJ 07302, USA", "country"=>"US", "state"=>"NJ", "county"=>"Hudson County", "city"=>"Jersey City", "street"=>"3 Paulmier Place", "house_number"=>"3", "postal_code"=>"07302"}}], @cache_hit=nil, @rate_limited=false>

1.9.3-p545 :004 > Regis.configure(:provider => 'ovi')
 => {:timeout=>3, :provider=>"ovi", :ip_provider=>:freegeoip, :language=>:en, :http_headers=>{}, :use_https=>false, :http_proxy=>nil, :https_proxy=>nil, :api_key=>nil, :cache=>nil, :cache_prefix=>"regis:", :app_id=>"6BfYFgVfbRGLufNa3YyH", :app_code=>"dT4mkeydz7V0oVQ01PDHQQ", :normalize=>true, :always_raise=>[], :units=>:mi, :distances=>:linear}

1.9.3-p545 :005 > Regis.search("3 paulmier place 07302")
 => #<Regis::Result::Ovi:0x007f82ccba99f0 @data=[{"location"=>{"lat"=>40.71881, "lng"=>-74.04585, "location_type"=>0.7, "confidence"=>0.7}, "address"=>{"formatted_address"=>"Paulmier Pl, Jersey City, NJ 07302 , United States of America", "country"=>"USA", "state"=>"NJ", "county"=>"Hudson", "city"=>"Jersey City", "street"=>"Paulmier Pl", "house_number"=>nil, "postal_code"=>"07302"}}], @cache_hit=nil, @rate_limited=false>
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






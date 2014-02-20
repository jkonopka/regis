# Regis

Regis provides an API to perform geocoding. It wraps providers such as Google behind a consistent interface.

how to change providers:  Regis.configure(:provider => :google) (default :google, select from :google,:ovi,:here,:test)

how to change timeout:  Regis.configure(:timeout => 10)  (default 3)



require 'spec_helper'

describe Regis::Provider::Ovi do

  let :subject do
    Regis::Provider::Ovi
  end

  describe '#search' do
    let :query do
      Regis::Query.new('39 E 30th St, New York')
    end

    let :sample_results do
      {
        'id' => 'ip-10-11-39-194.ec2.internal:20140318151627150:0000076:UyhjSgoLJ8IAADNUFxIAAAAD',
        'results' => [
          {
            'categories' => [
              {
                'id' => '9000284'
              }
            ],
            'properties' => {
              'addrAreaotherName' => 'Midtown South Central',
              'addrCityName' => 'New York',
              'addrCountryCode' => 'USA',
              'addrCountryName' => 'United States of America',
              'addrDistrictName' => 'Manhattan',
              'addrHouseNumber' => '39',
              'addrPopulation' => '8274527',
              'addrPostalCode' => '10016',
              'addrStateCode' => 'NY',
              'addrStateName' => 'New York',
              'addrStreetName' => 'E 30th St',
              'authoritative' => 'true',
              'geoDistance' => '8950912',
              'geoLatitude' => '40.74504852294922',
              'geoLongitude' => '-73.98375701904297',
              'language' => 'ENG',
              'title' => '39 E 30th St, New York, NY 10016, USA',
              'type' => 'Street',
              'volatileItemId' => 'Street;21627495;39;'
            }
          }
        ],
        'version' => '1.0'
      }
    end

    let :sample_result_normalized do
      {
        "location" => {
          "lat" => 40.74504852294922,
          "lng" => -73.98375701904297,
          "location_type" => 1.0,
          "confidence" => 1.0
        },
        "address" => {
          "formatted_address" => "39 E 30th St, New York, NY 10016 , United States of America",
          "country" => "USA",
          "state" => "NY",
          "county" => nil,
          "city" => "New York",
          "street" => "E 30th St",
          "house_number" => "39",
          "postal_code" => "10016"
        }
      }
    end

    it 'geocodes using Ovi API' do
      raw_results = sample_results

      stub = stub_request(:get, 'where.desktop.mos.svc.ovi.com/json').
        with(
          query: hash_including(
            q: '39 E 30th St, New York',
            dv: 'OviMapsAPI',
            la: 'en-US',
            lat: '0',
            lon: '0')
        ).
        to_return(status: 200,
          body: JSON.dump(raw_results),
          headers: {
            'Content-Type' => 'application/json; charset=utf-8'
          })

      provider = subject.new
      results = provider.search(query)
      results.should be_instance_of(Regis::Provider::Ovi::Results)
      results.raw_results.should eq raw_results
      results.results.length.should eq 1
      results.results[0].raw_result['properties']['title'].should eq(
        '39 E 30th St, New York, NY 10016, USA')
      results.as_json.should eq([sample_result_normalized])

      stub.should have_been_requested.times(1)
    end

    it 'caches result' do
      raw_results = sample_results

      stub = stub_request(:get, 'where.desktop.mos.svc.ovi.com/json').
        with(
          query: hash_including(
            q: '39 E 30th St, New York',
            dv: 'OviMapsAPI',
            la: 'en-US',
            lat: '0',
            lon: '0')
        ).
        to_return(status: 200,
          body: JSON.dump(raw_results),
          headers: {
            'Content-Type' => 'application/json; charset=utf-8'
          })

      results1 = subject.new.search(query)
      results2 = subject.new.search(query)
      results1.should eq results2

      stub.should have_been_requested.times(1)
    end
  end

end
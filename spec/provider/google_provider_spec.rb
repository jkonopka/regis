require 'spec_helper'

describe Regis::Provider::Google do

  let :subject do
    Regis::Provider::Google
  end

  describe '#search' do
    let :query do
      Regis::Query.new("221B Baker Street, London")
    end

    let :sample_results do
      {
        "results" => [
          {
            "address_components" => [
              {
                "long_name" => "221B",
                "short_name" => "221B",
                "types" => [
                  "street_number"
                ]
              },
              {
                "long_name" => "Baker Street",
                "short_name" => "Baker St",
                "types" => [
                  "route"
                ]
              },
              {
                "long_name" => "Marylebone",
                "short_name" => "Marylebone",
                "types" => [
                  "neighborhood",
                  "political"
                ]
              },
              {
                "long_name" => "London",
                "short_name" => "London",
                "types" => [
                  "locality",
                  "political"
                ]
              },
              {
                "long_name" => "Greater London",
                "short_name" => "Gt Lon",
                "types" => [
                  "administrative_area_level_2",
                  "political"
                ]
              },
              {
                "long_name" => "England",
                "short_name" => "England",
                "types" => [
                  "administrative_area_level_1",
                  "political"
                ]
              },
              {
                "long_name" => "United Kingdom",
                "short_name" => "GB",
                "types" => [
                  "country",
                  "political"
                ]
              },
              {
                "long_name" => "NW1 6XE",
                "short_name" => "NW1 6XE",
                "types" => [
                  "postal_code"
                ]
              },
              {
                "long_name" => "London",
                "short_name" => "London",
                "types" => [
                  "postal_town"
                ]
              }
            ],
            "formatted_address" => "221B Baker Street, Marylebone, London NW1 6XE, UK",
            "geometry" => {
              "location" => {
                "lat" => 51.5238101,
                "lng" => -0.1584409
              },
              "location_type" => "ROOFTOP",
              "viewport" => {
                "northeast" => {
                  "lat" => 51.5251590802915,
                  "lng" => -0.157091919708498
                },
                "southwest" => {
                  "lat" => 51.5224611197085,
                  "lng" => -0.159789880291502
                }
              }
            },
            "types" => [
              "street_address"
            ]
          }
        ],
        "status" => "OK"
      }
    end

    let :sample_result_normalized do
      {
        "location" => {
          "lat" => 51.5238101,
          "lng" => -0.1584409,
          "location_type" => "rooftop",
          "result_type" => "street_address",
          "accuracy" => true,
          "confidence" => 1.0
        },
        "address" => {
          "formatted_address" => "221B Baker Street, Marylebone, London NW1 6XE, UK",
          "country" => "GB",
          "state" => "England",
          "county" => "Gt Lon",
          "city" => "London",
          "street" => "221B Baker Street",
          "house_number" => "221B",
          "postal_code" => "NW1 6XE"
        }
      }
    end

    it 'geocodes using Google API' do
      raw_results = sample_results

      stub = stub_request(:get, "maps.googleapis.com/maps/api/geocode/json").
        with(
          query: hash_including(
            address: '221B Baker Street, London',
            language: 'en',
            sensor: 'false')
        ).
        to_return(status: 200,
          body: JSON.dump(raw_results),
          headers: {
            'Content-Type' => 'application/json; charset=utf-8'
          })

      provider = subject.new
      results = provider.search(query)
      results.should be_instance_of(Regis::Provider::Google::Results)
      results.raw_results.should eq raw_results
      results.results.length.should eq 1
      results.results[0].raw_result['formatted_address'].should eq(
        "221B Baker Street, Marylebone, London NW1 6XE, UK")
      results.as_json.should eq([sample_result_normalized])

      stub.should have_been_requested.times(1)
    end

    it 'caches result' do
      raw_results = sample_results

      stub = stub_request(:get, "maps.googleapis.com/maps/api/geocode/json").
        with(
          query: hash_including(
            address: '221B Baker Street, London',
            language: 'en',
            sensor: 'false')
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
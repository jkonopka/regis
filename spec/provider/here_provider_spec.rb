require 'spec_helper'

describe Regis::Provider::Here do

  let :subject do
    Regis::Provider::Here
  end

  before :each do
    Regis::Configuration.here = {
      app_id: 'some_app_id',
      app_code: 'some_app_code'
    }
  end

  describe '#search' do

    let :query do
      Regis::Query.new('39 E 30th St, New York')
    end

    let :sample_results do
      {
        'Response' => {
          'MetaInfo' => {
            'Timestamp' => '2014-03-18T15:48:00.847+0000'
          },
          'View' => [
            {
              '_type' => 'SearchResultsViewType',
              'ViewId' => 0,
              'Result' => [
                {
                  'Relevance' => 1.0,
                  'MatchLevel' => 'houseNumber',
                  'MatchQuality' => {
                    'City' => 1.0,
                    'Street' => [
                      1.0
                    ],
                    'HouseNumber' => 1.0
                  },
                  'MatchType' => 'pointAddress',
                  'Location' => {
                    'LocationId' => 'NT_jLrv5UrIVtduorvzPUCgrB_39',
                    'LocationType' => 'point',
                    'DisplayPosition' => {
                      'Latitude' => 40.7450485,
                      'Longitude' => -73.983757
                    },
                    'NavigationPosition' => [
                      {
                        'Latitude' => 40.7448616,
                        'Longitude' => -73.9838791
                      }
                    ],
                    'MapView' => {
                      'TopLeft' => {
                        'Latitude' => 40.7461727,
                        'Longitude' => -73.9852408
                      },
                      'BottomRight' => {
                        'Latitude' => 40.7439244,
                        'Longitude' => -73.9822732
                      }
                    },
                    'Address' => {
                      'Label' => '39 E 30th St, New York, NY 10016, United States',
                      'Country' => 'USA',
                      'State' => 'NY',
                      'County' => 'New York',
                      'City' => 'New York',
                      'Street' => 'E 30th St',
                      'HouseNumber' => '39',
                      'PostalCode' => '10016',
                      'AdditionalData' => [
                        {
                          'value' => 'United States',
                          'key' => 'CountryName'
                        },
                        {
                          'value' => 'New York',
                          'key' => 'StateName'
                        }
                      ]
                    }
                  }
                }
              ]
            }
          ]
        }
      }
    end

    let :sample_result_normalized do
      {
        'location' => {
          'lat' => 40.7450485,
          'lng' => -73.983757,
          'location_type' => 0.0,
          'confidence' => 1.0
        },
        'address' => {
          'formatted_address' => '39 E 30th St, New York, NY 10016, United States',
          'country' => 'USA',
          'state' => 'NY',
          'county' => 'USA',
          'city' => 'New York',
          'street' => 'E 30th St',
          'house_number' => '39',
          'postal_code' => '10016'
        }
      }
    end

    it 'geocodes using Here API' do
      raw_results = sample_results

      stub = stub_request(:get, 'geocoder.api.here.com/6.2/geocode.json').
        with(
          query: hash_including(
            searchtext: '39 E 30th St, New York',
            gen: '4',
            app_id: 'some_app_id',
            app_code: 'some_app_code')
        ).
        to_return(status: 200,
          body: JSON.dump(raw_results),
          headers: {
            'Content-Type' => 'application/json; charset=utf-8'
          })

      provider = subject.new
      results = provider.search(query)
      results.should be_instance_of(Regis::Provider::Here::Results)
      results.raw_results.should eq raw_results
      results.results.length.should eq 1
      results.results[0].raw_result['Location']['Address']['Label'].should eq(
        '39 E 30th St, New York, NY 10016, United States')
      results.as_json.should eq([sample_result_normalized])

      stub.should have_been_requested.times(1)
    end

    it 'caches result' do
      raw_results = sample_results

      stub = stub_request(:get, 'geocoder.api.here.com/6.2/geocode.json').
        with(
          query: hash_including(
            searchtext: '39 E 30th St, New York',
            gen: '4',
            app_id: 'some_app_id',
            app_code: 'some_app_code')
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
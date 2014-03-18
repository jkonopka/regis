require 'spec_helper'

describe 'API' do

  include Rack::Test::Methods

  def app
    Regis::V1
  end

  describe 'POST /geocode' do
    context 'when missing address' do
      it 'returns 400' do
        post '/geocode', {}
        last_response.status.should eq 400
      end
    end

    context 'when empty address' do
      it 'returns 400' do
        post '/geocode', {address: ''}
        last_response.status.should eq 400
      end
    end

    context 'when valid address' do

      let! :provider do
        Regis::Provider::Test.new
      end

      let :sample_results do
        Regis::Provider::Test::Results.new([
          {
            'latitude' => 40.7143528,
            'longitude' => -74.0059731,
            'address' => 'New York, NY, USA',
            'state' => 'New York',
            'state_code' => 'NY',
            'country' => 'United States',
            'country_code' => 'US'
          }
        ])
      end

      it 'performs geocoding using provider' do
        query = Regis::Query.new("221B Baker Street, London")

        provider.stub(:search).and_return(sample_results)
        provider.should_receive(:search).
          with(query).
          exactly(1).times

        Regis::Provider::Test.stub(:new).and_return(provider)

        post '/geocode', {
          address: query.text,
          config: {
            provider: 'test'
          }
        }
        last_response.status.should eq 200

        results = JSON.parse(last_response.body)
        results.should be_kind_of(Hash)
        results['data'].length.should eq 1
        results['data'].should eq [
          {
            'latitude' => 40.7143528,
            'longitude' => -74.0059731,
            'address' => 'New York, NY, USA',
            'state' => 'New York',
            'state_code' => 'NY',
            'country' => 'United States',
            'country_code' => 'US'
          }
        ]
      end

      it 'records log entry' do
        provider.stub(:search).and_return(sample_results)
        Regis::Provider::Test.stub(:new).and_return(provider)

        post '/geocode', {
          address: 'Blah',
          config: {
            provider: 'test'
          }
        }
        last_response.status.should eq 200

        entries = Regis::GeocodeLogEntry.all
        entries.length.should eq 1
        entries[0].provider.should eq 'test'
        entries[0].query.should eq({'text' => 'Blah', 'options' => {}})
        entries[0].result.should eq sample_results.as_json
        entries[0].created_at.should >= Time.now - 5.minutes
      end

    end
  end

end
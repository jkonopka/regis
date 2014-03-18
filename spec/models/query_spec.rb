require 'spec_helper'

describe Regis::Query do

  describe '#initialize' do
    ['', '   ', "\t", "\n", "\n  "].each do |s|
      it "throws exception on empty string #{s.inspect}" do
        -> {
          Regis::Query.new(s)
        }.should raise_error(Regis::InvalidQueryError)
      end
    end

    it 'throws exception on empty array pair' do
      -> {
        Regis::Query.new([])
      }.should raise_error(Regis::InvalidQueryError)
    end
  end

  describe "#eql?" do
    context 'when address' do
      it_implements 'equality' do
        let(:a) { Regis::Query.new("221B Baker Street, London") }
        let(:b) { Regis::Query.new("221B Baker Street, London") }
      end

      it_implements 'inequality' do
        let(:a) { Regis::Query.new("221B Baker Street, London") }
        let(:b) { Regis::Query.new("221A Baker Street, London") }
      end
    end

    context 'when lat/lng pair' do
      it_implements 'equality' do
        let(:a) { Regis::Query.new([40.7449921, -73.983779]) }
        let(:b) { Regis::Query.new([40.7449921, -73.983779]) }
      end

      it_implements 'inequality' do
        let(:a) { Regis::Query.new([40.7449921, -73.983779]) }
        let(:b) { Regis::Query.new([41.7449921, -72.983779]) }
      end
    end
  end

  describe '#coordinates?' do
    context 'when string' do
      it 'returns true' do
        Regis::Query.new('40.7449921,-73.983779').coordinates?.should eq true
      end

      it 'ignores spaces' do
        Regis::Query.new('  40.7449921,-73.983779  ').coordinates?.should eq true
        Regis::Query.new('  40.7449921,         -73.983779  ').coordinates?.should eq true
      end
    end

    context 'when lat/lng pair' do
      it 'returns true' do
        Regis::Query.new([40.7449921, -73.983779]).coordinates?.should eq true
      end

      it 'returns false when invalid' do
        Regis::Query.new([1.1]).coordinates?.should eq false
        Regis::Query.new([2.2, 3.3, 4.4]).coordinates?.should eq false
        Regis::Query.new([2.2, 3.3, 4.4, 5.5]).coordinates?.should eq false
      end
    end

    context 'when address' do
      it 'returns false' do
        Regis::Query.new('39 e. 30th st').coordinates?.should eq false
        Regis::Query.new('london').coordinates?.should eq false
      end
    end
  end

  describe '#coordinates' do
    context 'when string' do
      it 'returns coordinates' do
        Regis::Query.new('40.7449921,-73.983779').
          coordinates.should eq [40.7449921, -73.983779]
        Regis::Query.new('   40.7449921,-73.983779   ').
          coordinates.should eq [40.7449921, -73.983779]
      end

      it 'ignores spaces' do
        Regis::Query.new('   40.7449921,-73.983779   ').
          coordinates.should eq [40.7449921, -73.983779]
        Regis::Query.new('   40.7449921,     -73.983779   ').
          coordinates.should eq [40.7449921, -73.983779]
      end
    end

    context 'when lat/lng pair' do
      it 'returns coordinates' do
        Regis::Query.new([40.7449921, -73.983779]).
          coordinates.should eq [40.7449921, -73.983779]
      end
    end
  end

end
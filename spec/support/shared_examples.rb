require 'spec_helper'

shared_examples 'equality' do
  it 'returns true if objects are equal' do
    a.eql?(b).should eq true
  end
end

shared_examples 'inequality' do
  it 'returns false if objects are not equal' do
    a.eql?(b).should eq false
  end
end

require 'spec_helper'

describe ApiClient do
  let(:params) { { name: 'SomeClient'} }
  let(:client) { described_class.new(params)}

  it "generates token" do
    client.save!
    expect(client.authentication_token).to be_present
  end
end

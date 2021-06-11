require 'spec_helper'

describe Record::SRV do
  before(:each) do
    @srv = described_class.new
  end
  
  it "should have tests" 

  it "should support priorities" do
    @srv.supports_prio?.should be_truthy
  end
end

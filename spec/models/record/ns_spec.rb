require 'spec_helper'

describe Record::NS, "when new" do
  before(:each) do
    @ns = described_class.new
  end

  it "should be invalid by default" do
    @ns.should_not be_valid
  end

  it "should require content" do
    @ns.should have(2).error_on(:content)
  end

end

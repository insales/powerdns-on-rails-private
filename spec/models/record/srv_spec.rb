require 'spec_helper'

describe Record::SRV do
  let(:record) { described_class.new }

  it "should be invalid by default" do
    record.should_not be_valid
  end

  it "should require content" do
    record.should have(1).error_on(:content)
  end

  it "should support priorities" do
    record.supports_prio?.should be_truthy
  end
end

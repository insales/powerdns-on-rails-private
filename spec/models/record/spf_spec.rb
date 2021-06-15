require 'spec_helper'

describe Record::SPF do
  let(:record) { described_class.new }

  it "should be invalid by default" do
    record.should_not be_valid
  end

  it "should require content" do
    record.should have(1).error_on(:content)
  end
end

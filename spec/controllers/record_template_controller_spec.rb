require 'spec_helper'

describe RecordTemplatesController, "when updating SOA records" do
  before(:each) do
    sign_in(FactoryBot.create(:admin))
    @zt = FactoryBot.create(:zone_template)
  end

  it "should create valid templates" do
    expect {
      xhr :post, :create, :record_template => {
        :retry => "7200", :primary_ns => 'ns1.provider.net',
        :contact => 'east-coast@example.com', :refresh => "10800", :minimum => "10800",
        :expire => "604800", :record_type => "SOA"
      }, :zone_template => { :id => @zt.id }

    }.to change( RecordTemplate, :count ).by(1)
  end

  it "should accept a valid update" do
    target_soa = FactoryBot.create(:template_soa, :zone_template => @zt)

    xhr :put, :update, :id => target_soa.id, :record_template => {
      :retry => "7200", :primary_ns => 'ns1.provider.net',
      :contact => 'east-coast@example.com', :refresh => "10800", :minimum => "10800",
      :expire => "604800"
    }

    target_soa.reload
    target_soa.primary_ns.should eql('ns1.provider.net')
  end

  describe "destroy" do
    let(:target_record) { FactoryBot.create(:template_mx) }
    it "should destroy templates" do
      expect do
        xhr :delete, :destroy, id: target_record.id
      end.to change(target_record.class, :count).by(-1)
    end
  end
end

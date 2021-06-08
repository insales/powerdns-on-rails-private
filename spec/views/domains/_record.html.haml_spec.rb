require 'spec_helper'

describe "domains/_record" do
  context "for a user" do

    let(:user) { FactoryGirl.create :admin }
    before(:each) do
      expect(user).to be_persisted
      allow(view).to receive(:current_user).and_return(user)
      domain = FactoryGirl.create(:domain, name: "example.com")
      @record = FactoryGirl.create(:ns, :domain => domain)

      render :partial => 'domains/record', :object => @record
    end

    it "should have a marker row (used by AJAX)" do
      rendered.should have_css("tr#marker_ns_#{@record.id}")
    end

    it "should have a row with the record details" do
      rendered.should have_css("tr#show_ns_#{@record.id} > td", :text => "") # shortname
      rendered.should have_css("tr#show_ns_#{@record.id} > td", :text => "") # ttl
      rendered.should have_css("tr#show_ns_#{@record.id} > td", :text => "NS") # shortname
      rendered.should have_css("tr#show_ns_#{@record.id} > td", :text => "") # prio
      rendered.should have_css("tr#show_ns_#{@record.id} > td", :text => "ns1.example.com")
    end

    it "should have a row for editing record details" do
      rendered.should have_css("tr#edit_ns_#{@record.id} > td[colspan='7'] > form")
    end

    it "should have links to edit/remove the record" do
      rendered.should have_css("a[onclick^=editRecord]")
      rendered.should have_css("a > img[src*=database_delete]")
    end
  end

  context "for a SLAVE domain" do

    before(:each) do
      allow(view).to receive(:current_user).and_return(FactoryGirl.create(:admin))
      domain = FactoryGirl.create(:domain, :type => 'SLAVE', :master => '127.0.0.1')
      @record = domain.a_records.create( :name => 'foo', :content => '127.0.0.1' )
      render :partial => 'domains/record', :object => @record
      expect(@record).to be_persisted
    end

    it "should not have tooltips ready" do
      rendered.should_not have_css("div#record-template-edit-#{@record.id}")
      rendered.should_not have_css("div#record-template-delete-#{@record.id}")
    end

    it "should have a row with the record details" do
      rendered.should have_css("tr#show_a_#{@record.id} > td:nth-child(1)", :text => "foo") # shortname
      rendered.should have_css("tr#show_a_#{@record.id} > td:nth-child(2)", :text => "") # ttl
      rendered.should have_css("tr#show_a_#{@record.id} > td:nth-child(3)", :text => "A")
      rendered.should have_css("tr#show_a_#{@record.id} > td:nth-child(4)", :text => "") # prio
      rendered.should have_css("tr#show_a_#{@record.id} > td:nth-child(5)", :text => "127.0.0.1")
    end

    it "should not have a row for editing record details" do
      rendered.should_not have_css("tr#edit_ns_#{@record.id} > td[colspan='7'] > form")
    end

    it "should not have links to edit/remove the record" do
      rendered.should_not have_css("a[onclick^=editRecord]")
      rendered.should_not have_css("a > img[src*=database_delete]")
    end
  end

  context "for a token" do

    before(:each) do
      @domain = FactoryGirl.create(:domain, name: "example.com")
      allow(view).to receive(:current_user).and_return(nil)
      token = FactoryGirl.create(:auth_token, :domain => @domain, :user => FactoryGirl.create(:admin))
      allow(view).to receive(:current_token).and_return(token)
    end

    it "should not allow editing NS records" do
      record = FactoryGirl.create(:ns, :domain => @domain)

      render :partial => 'domains/record', :object => record

      rendered.should_not have_css("a[onclick^=editRecord]")
      rendered.should_not have_css("tr#edit_ns_#{record.id}")
    end

    it "should not allow removing NS records" do
      record = FactoryGirl.create(:ns, :domain => @domain)

      render :partial => 'domains/record', :object => record

      rendered.should_not have_css("a > img[src*=database_delete]")
    end

    it "should allow edit records that aren't protected" do
      expect(@domain).not_to be_slave
      record = FactoryGirl.create(:a, :domain => @domain)
      render :partial => 'domains/record', :object => record

      # binding.pry
      rendered.should have_css("a[onclick^=editRecord]")
      rendered.should_not have_css("a > img[src*=database_delete]")
      rendered.should have_css("tr#edit_a_#{record.id}")
    end

    it "should allow removing records if permitted" do
      record = FactoryGirl.create(:a, :domain => @domain)
      token = AuthToken.new(
        :domain => @domain
      )
      token.remove_records=( true )
      token.can_change( record )
      allow(view).to receive(:current_token).and_return(token)

      render :partial => 'domains/record', :object => record

      rendered.should have_css("a > img[src*=database_delete]")
    end
  end
end

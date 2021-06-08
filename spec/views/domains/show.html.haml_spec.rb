require 'spec_helper'

describe "domains/show.html.haml" do
  context "for all users" do

    let(:domain) { FactoryGirl.create(:domain, name: "example.com") }

    before(:each) do
      allow(view).to receive(:current_user).and_return(FactoryGirl.create(:admin))
      allow(view).to receive(:current_token).and_return(nil)
      @domain = domain
      assign(:domain, @domain)
      assign(:users, User.active_owners)

      render :template => "/domains/show", :layout => "layouts/application"
    end

    it "should have the domain name in the title and dominant on the page" do
      rendered.should have_css( "title", :text => domain.name)
      rendered.should have_css( "h1", :text => domain.name)
    end
  end

  context "for admins and domains without owners" do

    before(:each) do
      allow(view).to receive(:current_user).and_return(FactoryGirl.create(:admin))
      allow(view).to receive(:current_token).and_return(nil)
      @domain = FactoryGirl.create(:domain)
      assign(:domain, @domain)
      assign(:users, User.active_owners)

      render
    end

    it "should display the owner" do
      rendered.should have_css( "div#owner-info" )
    end

    it "should allow changing the SOA" do
      rendered.should have_css( "div#soa-form")
    end

    it "should have a form for adding new records" do
      rendered.should have_css( "div#record-form-div" )
    end

    it "should have not have an additional warnings for removing" do
      rendered.should_not have_css('div#warning-message')
      rendered.should_not have_css('a[onclick*=deleteDomain]')
    end
  end

  context "for admins and domains with owners" do

    before(:each) do
      allow(view).to receive(:current_user).and_return(FactoryGirl.create(:admin))
      allow(view).to receive(:current_token).and_return(nil)
      @domain = FactoryGirl.create(:domain, :user => FactoryGirl.create(:quentin))
      assign(:domain, @domain)
      assign(:users, User.active_owners)

      render
    end

    it "should offer to remove the domain" do
      rendered.should have_css( "a img[id$=delete-zone]" )
    end

    it "should have have an additional warnings for removing" do
      rendered.should have_css('div#warning-message')
      rendered.should have_css('a[onclick*=deleteDomain]')
    end
  end

  context "for owners" do
    before(:each) do
      quentin = FactoryGirl.create(:quentin)
      allow(view).to receive(:current_user).and_return(quentin)
      allow(view).to receive(:current_token).and_return(nil)

      @domain = FactoryGirl.create(:domain, :user => quentin)
      assign(:domain, @domain)

      render
    end

    it "should display the owner" do
      rendered.should_not have_css( "div#ownerinfo" )
    end

    it "should allow for changing the SOA" do
      rendered.should have_css( "div#soa-form" )
    end

    it "should have a form for adding new records" do
      rendered.should have_css( "div#record-form-div" )
    end

    it "should offer to remove the domain" do
      rendered.should have_css( "a img[id$=delete-zone]" )
    end

    it "should have not have an additional warnings for removing" do
      rendered.should_not have_css('div#warning-message')
      rendered.should_not have_css('a[onclick*=deleteDomain]')
    end
  end

  context "for SLAVE domains" do

    before(:each) do
      allow(view).to receive(:current_user).and_return(FactoryGirl.create(:admin))
      allow(view).to receive(:current_token).and_return(nil)

      @domain = FactoryGirl.create(:domain, :type => 'SLAVE', :master => '127.0.0.1')
      assign(:domain, @domain)
      assign(:users, User.active_owners)

      render
    end

    it "should show the master address" do
      rendered.should have_css('#domain-name td', :text => "Master server")
      rendered.should have_css('#domain-name td', :text => @domain.master)
    end

    it "should not allow for changing the SOA" do
      rendered.should_not have_css( "div#soa-form" )
    end

    it "should not have a form for adding new records" do
      rendered.should_not have_css( "div#record-form-div" )
    end

    it "should offer to remove the domain" do
      rendered.should have_css( "a img[id$=delete-zone]" )
    end
  end

  context "for token users" do
    before(:each) do
      @admin = FactoryGirl.create(:admin)
      @domain = FactoryGirl.create(:domain)
      assign(:domain, @domain)

      allow(view).to receive(:current_token).and_return(FactoryGirl.create(:auth_token, :user => @admin, :domain => @domain))
      allow(view).to receive(:current_user).and_return(nil)
    end

    it "should not offer to remove the domain" do
      render

      rendered.should_not have_css( "a img[id$=delete-zone]" )
    end

    it "should not offer to edit the SOA" do
      render

      rendered.should_not have_css( "a[onclick^=showSOAEdit]")
      rendered.should_not have_css( "div#soa-form" )
    end

    it "should only allow new record if permitted (FALSE)" do
      render

      rendered.should_not have_css( "div#record-form-div" )
    end

    it "should only allow new records if permitted (TRUE)" do
      token = AuthToken.new(
        :domain => @domain
      )
      token.allow_new_records=( true )
      allow(view).to receive(:current_token).and_return(token)
      render

      rendered.should have_css( "div#record-form-div" )
    end
  end
end

require 'spec_helper'

describe "audits/domain.html.haml" do
  context "and domain audits" do

    before(:each) do
      @domain = FactoryGirl.create(:domain)
    end

    it "should handle no audit entries on the domain" do
      expect(@domain).to receive(:audits).and_return([])
      assign(:domain, @domain)

      render

      rendered.should have_css("em", :text => "No revisions found for the domain")
    end

    it "should handle audit entries on the domain" do
      audit = Audit.new(
        :auditable => @domain,
        :created_at => Time.now,
        :version => 1,
        :audited_changes => {},
        :action => 'create',
        :username => 'admin'
      )
      expect(@domain).to receive(:audits).at_most(:twice).and_return([ audit ])

      assign(:domain, @domain)
      render

      rendered.should have_css("ul > li > a", :text => "1 create by")
    end

  end

  context "and resource record audits" do

    before(:each) do
      Audit.as_user( 'admin' ) do
        @domain = FactoryGirl.create(:domain)
      end
    end

    it "should handle no audit entries" do
      expect(@domain).to receive(:associated_audits).at_most(:twice).and_return([])
      assign(:domain, @domain)

      render

      rendered.should have_css("em", :text => "No revisions found for any resource records of the domain")
    end

    it "should handle audit entries" do
      assign(:domain, @domain)

      render

      rendered.should have_css("ul > li > a", :text => "1 create by admin")
    end

  end
end

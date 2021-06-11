require 'spec_helper'

describe AuditsHelper, "display_hash" do

  it "should handle a blank changes hash" do
    helper.display_hash( nil ).should eql('')
  end

  it "should have a way to display the changes hash with blank stipped" do
    result = helper.display_hash( 'key' => 'value', :blank => nil )
    result.should eql("<em>key</em>: value")
  end

  it "should seperate items in the change hash with breaks" do
    result = helper.display_hash( 'one' => 'one', 'two' => 'two' )
    result.should match(/<br \/>/)
  end

end

describe AuditsHelper, "link_to_domain_audit" do

  it "should handle an existing domain & existing user" do
    Audit.as_user( FactoryBot.create(:admin) ) do
      domain = FactoryBot.create(:domain)
      audit = domain.audits.first

      results = helper.link_to_domain_audit( audit )

      results.should match(/1 create by admin/)
    end
  end

  it "should handle existing domains & removed users" do
    Audit.as_user('admin') do
    audit = FactoryBot.create(:domain).audits.first

      results = helper.link_to_domain_audit( audit )

      results.should match(/1 create by admin/)
    end
  end

  it "should handle removed domains & existing users" do
    Audit.as_user( FactoryBot.create(:admin) ) do
      domain = FactoryBot.create(:domain)
      domain.destroy
      audit = domain.audits.last

      results = helper.link_to_domain_audit( audit )

      results.should match(/2 destroy by admin/)
    end
  end

  it "should handle removed domains & removed users" do
    Audit.as_user('admin') do
      domain = FactoryBot.create(:domain)
      domain.destroy
      audit = domain.audits.last

      results = helper.link_to_domain_audit( audit )

      results.should match(/2 destroy by admin/)
    end
  end

end

describe AuditsHelper, "link_to_record_audit" do
  let(:domain) { FactoryBot.create(:domain, name: "example.com") }

  it "should handle an existing record & existing user" do
    Audit.as_user( FactoryBot.create(:admin) ) do
      record = FactoryBot.create(:a, :domain => domain)
      audit = record.audits.first

      result = helper.link_to_record_audit( audit )
      result.should match(/A \(example\.com\) 1 create by admin/)
    end
  end

  it "should handle existing records & removed users" do
    Audit.as_user( 'admin' ) do
      record = FactoryBot.create(:a, :domain => domain)
      audit = record.audits.first

      # make sure sti is not leaking (TODO: move to other test)
      expect(audit.auditable_type).to eq 'Record'

      result = helper.link_to_record_audit( audit )
      result.should match(/A \(example\.com\) 1 create by admin/)
    end
  end

  it "should handle removed records & existing users" do
    Audit.as_user( FactoryBot.create(:admin) ) do
      record = FactoryBot.create(:a, :domain => domain)
      record.destroy
      audit = record.audits.last

      result = helper.link_to_record_audit( audit )
      result.should match(/A \(example\.com\) 2 destroy by admin/)
    end
  end

  it "should handle removed records & removed users" do
    Audit.as_user( 'admin' ) do
      record = FactoryBot.create(:a, :domain => domain)
      record.destroy
      audit = record.audits.last

      result = helper.link_to_record_audit( audit )
      result.should match(/A \(example\.com\) 2 destroy by admin/)
    end
  end

  it "should handle records without a 'type' key in the changes hash" do
    audit = Audit.new(
      :auditable => FactoryBot.create(:a, :domain => domain),
      :associated => domain,
      :action => 'create',
      :version => 1,
      :user => FactoryBot.create(:admin),
      :audited_changes => { 'name' => 'example.com' }
    )

    result = helper.link_to_record_audit( audit )
    result.should match(/A \(example\.com\) 1 create by admin/)
  end

  it "should handle removed records without a 'type' key in the changes hash" do
    audit = Audit.new(
      :auditable => nil,
      :associated => domain,
      :action => 'destroy',
      :version => 1,
      :user => FactoryBot.create(:admin),
      :audited_changes => { 'name' => 'local.example.com' }
    )

    result = helper.link_to_record_audit( audit )
    result.should match(/\[UNKNOWN\] \(local\.example\.com\) 1 destroy by admin/)
  end

end

describe AuditsHelper, "audit_user" do

  it "should display user logins if present" do
    audit = Audit.new(
      :auditable => nil,
      :associated => FactoryBot.create(:domain),
      :action => 'destroy',
      :version => 1,
      :user => FactoryBot.create(:admin),
      :audited_changes => { 'name' => 'local.example.com' }
    )

    helper.audit_user( audit ).should == 'admin'
  end

  it "should display usernames if present" do
    audit = Audit.new(
      :auditable => nil,
      :associated => FactoryBot.create(:domain),
      :action => 'destroy',
      :version => 1,
      :username => 'foo',
      :audited_changes => { 'name' => 'local.example.com' }
    )

    helper.audit_user( audit ).should == 'foo'
  end

  it "should not bork on missing user information" do
    audit = Audit.new(
      :auditable => nil,
      :associated => FactoryBot.create(:domain),
      :action => 'destroy',
      :version => 1,
      :audited_changes => { 'name' => 'local.example.com' }
    )

    helper.audit_user( audit ).should == 'UNKNOWN'
  end
end

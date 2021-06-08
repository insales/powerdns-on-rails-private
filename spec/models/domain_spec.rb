# -*- encoding : utf-8 -*-
require 'spec_helper'

describe "New 'untyped'", Domain do
  subject { Domain.new }

  it "should be NATIVE by default" do
    # subject.type.should == 'NATIVE'
    subject.type.should == DOMAIN_DEFAULTS[:type]
  end

  it "should not accept rubbish types" do
    subject.type = 'DOMINANCE'
    subject.should have(1).error_on(:type)
  end

  describe '#name=' do
    it 'converts value to punicode' do
      expect { subject.name = 'test.com' }.to change { subject.name }.to('test.com')
      expect { subject.name = 'тест.рф' }.to change { subject.name }.to('xn--e1aybc.xn--p1ai')
      expect { subject.name = nil }.to change { subject.name }.to(nil)
    end
  end
end

describe "New MASTER/NATIVE", Domain do
  subject { Domain.new }

  it "should require a name" do
    subject.should have(1).error_on(:name)
  end

  it "should not allow duplicate names" do
    FactoryBot.create(:domain, name: "example.com")
    subject.name = "example.com"
    subject.should have(1).error_on(:name)
  end

  it "should bail out on missing SOA fields" do
    subject.primary_ns = nil
    subject.should have(1).error_on( :primary_ns )
  end

  it "should be NATIVE by default" do
    # subject.type.should eql('NATIVE')
    subject.type.should eql(DOMAIN_DEFAULTS[:type])
  end

  it "should not require a MASTER" do
    subject.should have(:no).errors_on(:master)
  end
end

describe "New SLAVE", Domain do
  subject { Domain.new( :type => 'SLAVE' ) }

  it "should require a master address" do
    subject.should have(1).error_on(:master)
  end

  it "should require a valid master address" do
    subject.master = 'foo'
    subject.should have(1).error_on(:master)

    subject.master = '127.0.0.1'
    subject.should have(:no).errors_on(:master)
  end

  it "should not bail out on missing SOA fields" do
    subject.should have(:no).errors_on( :primary_ns )
  end
end

describe Domain, "when loaded" do
  before(:each) do
    @domain = FactoryBot.create(:domain, name: "example.com")
  end

  it "should have a name" do
    @domain.name.should eql('example.com')
  end

  it "should have an SOA record" do
    @domain.soa_record.should be_a_kind_of( SOA )
  end

  it "should have NS records" do
    ns1 = FactoryBot.create(:ns, :domain => @domain)
    ns2 = FactoryBot.create(:ns, :domain => @domain)
    ns = @domain.ns_records
    ns.should be_a_kind_of( Array )
    ns.should include( ns1 )
    ns.should include( ns2 )
  end

  it "should have MX records" do
    mx_f = FactoryBot.create(:mx, :domain => @domain)
    mx = @domain.mx_records
    mx.should be_a_kind_of( Array )
    mx.should include( mx_f )
  end

  it "should have A records" do
    a_f = FactoryBot.create(:a, :domain => @domain)
    a = @domain.a_records
    a.should be_a_kind_of( Array )
    a.should include( a_f )
  end

  it "should give access to all records excluding the SOA" do
    FactoryBot.create(:a, :domain => @domain)
    @domain.records_without_soa.size.should eq 1 #be( @domain.records.size - 1 )
    expect(@domain.records_without_soa.map(&:class)).not_to include(SOA)
  end

  it "should not complain about missing SOA fields" do
    @domain.should have(:no).errors_on(:primary_ns)
  end
end

describe Domain, "scopes" do
  let(:quentin) { FactoryBot.create(:quentin) }
  let(:aaron) { FactoryBot.create(:aaron) }
  let(:quentin_domain) { FactoryBot.create(:domain, :user => quentin) }
  let(:aaron_domain) { FactoryBot.create(:domain, :name => 'example.org', :user => aaron) }
  let(:admin) { FactoryBot.create(:admin) }

  it "should show all domains to an admin" do
    quentin_domain
    aaron_domain

    Domain.user( admin ).all.should include(quentin_domain)
    Domain.user( admin ).all.should include(aaron_domain)
  end

  it "should restrict owners" do
    quentin_domain
    aaron_domain

    Domain.user( quentin ).all.should include(quentin_domain)
    Domain.user( quentin ).all.should_not include(aaron_domain)

    Domain.user( aaron ).all.should_not include(quentin_domain)
    Domain.user( aaron ).all.should include(aaron_domain)
  end

  it "should restrict authentication tokens"
end

describe Domain, "NATIVE/MASTER when created" do
  it "with additional attributes should create an SOA record" do
    domain = Domain.new
    domain.name = 'example.org'
    domain.primary_ns = 'ns1.example.org'
    domain.contact = 'admin@example.org'
    domain.refresh = 10800
    domain.retry = 7200
    domain.expire = 604800
    domain.minimum = 10800

    domain.save.should be_truthy
    domain.soa_record.should_not be_nil
    domain.soa_record.primary_ns.should eql('ns1.example.org')
  end

  it "with bulk additional attributes should be acceptable" do
    domain = Domain.new(
      :name => 'example.org',
      :primary_ns => 'ns1.example.org',
      :contact => 'admin@example.org',
      :refresh => 10800,
      :retry => 7200,
      :expire => 608400,
      :minimum => 10800
    )

    domain.save.should be_truthy
    domain.soa_record.should_not be_nil
    domain.soa_record.primary_ns.should eql('ns1.example.org')
  end
end

describe Domain, "SLAVE when created" do
  before(:each) do
    @domain = Domain.new( :type => 'SLAVE' )
  end

  it "should create with SOA requirements or SOA record" do
    @domain.name = 'example.org'
    @domain.master = '127.0.0.1'

    @domain.save.should be_truthy
    @domain.soa_record.should be_nil
  end
end

describe Domain, "when deleting" do
  it "should delete its records as well" do
    domain = FactoryBot.create(:domain)
    expect {
      domain.destroy
    }.to change(Record, :count).by(-domain.records.size)
  end
end

describe Domain, "when searching" do
  before(:each) do
    @quentin = FactoryBot.create(:quentin)
    FactoryBot.create(:domain, :user => @quentin)
  end

  it "should return results for admins" do
    Domain.search('exa', 1, FactoryBot.create(:admin)).should_not be_empty
  end

  it "should return results for users" do
    Domain.search('exa', 1, @quentin).should_not be_empty
  end

  it "should return unscoped results" do
    Domain.search('exa', 1).should_not be_empty
  end
end

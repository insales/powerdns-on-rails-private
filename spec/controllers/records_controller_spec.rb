require 'spec_helper'

describe RecordsController, ", users, and non-SOA records" do
  before( :each ) do
    sign_in(FactoryBot.create(:admin))

    @domain = FactoryBot.create(:domain)
  end

  # Test adding various records
  [
   { :name => '', :ttl => '86400', :type => 'NS', :content => 'ns3.example.com' },
   { :name => '', :ttl => '86400', :type => 'A', :content => '127.0.0.1' },
   { :name => '', :ttl => '86400', :type => 'MX', :content => 'mail.example.com', :prio => '10' },
   { :name => 'foo', :ttl => '86400', :type => 'CNAME', :content => 'bar.example.com' },
   { :name => '', :ttl => '86400', :type => 'AAAA', :content => '::1' },
   { :name => '', :ttl => '86400', :type => 'TXT', :content => 'Hello world' },
   { :name => '166.188.77.208.in-addr.arpa.', :type => 'PTR', :content => 'www.example.com' },
   { :type => 'SPF', content: "v=spf1 -all" },
   # TODO: Test these
   { :type => 'LOC', content: "52 22 23.000 N 4 53 32.000 E -2.00m 0.00m 10000m 10m" },
  ].each do |record|
    it "should create a #{record[:type]} record when valid" do
      pending "Still need test for #{record[:type]}" if record.delete(:pending)

      expect {
        post :create, params: { :domain_id => @domain.id, :record => record }, xhr: true
      }.to change( @domain.records, :count ).by(1)

      assigns(:domain).should_not be_nil
      assigns(:record).should_not be_nil
    end
  end

  it "shouldn't save when invalid" do
    params = {
      'name' => "",
      'ttl' => "864400",
      'type' => "NS",
      'content' => ""
    }

    post :create, params: { domain_id: @domain.id, record: params }, xhr: true

    response.should render_template( 'records/create' )
  end

  it "should update when valid" do
    record = FactoryBot.create(:ns, :domain => @domain)

    params = {
      'name' => "",
      'ttl' => "864400",
      'type' => "NS",
      'content' => "n4.example.com"
    }

    put :update, params: { :id => record.id, :domain_id => @domain.id, :record => params }, xhr: true

    response.should render_template("records/update")
  end

  it "shouldn't update when invalid" do
    record = FactoryBot.create(:ns, :domain => @domain)

    params = {
      'name' => "@",
      'ttl' => '',
      'type' => "NS",
      'content' => ""
    }

    expect {
      put :update, params: { :id => record.id, :domain_id => @domain.id, :record => params }, xhr: true
      record.reload
    }.to_not change( record, :content )

    response.should_not be_redirect
    response.should render_template( "records/update" )
  end

  it "should destroy when requested to do so" do
    delete :destroy, params: { :domain_id => @domain.id, :id => FactoryBot.create(:mx, :domain => @domain).id }

    response.should be_redirect
    response.should redirect_to( domain_path( @domain ) )
  end
end

describe RecordsController, ", users, and SOA records" do
  it "should update when valid" do
    sign_in( FactoryBot.create(:admin) )

    target_soa = FactoryBot.create(:domain).soa_record

    put :update_soa, params: {
      :id => target_soa.id,
      :domain_id => target_soa.domain.id,
      :soa => {
        :primary_ns => 'ns1.example.com', :contact => 'dnsadmin@example.com',
        :refresh => "10800", :retry => "10800", :minimum => "10800", :expire => "604800"
      }
    }, xhr: true

    target_soa.reload
    target_soa.contact.should eql('dnsadmin@example.com')
  end
end

describe RecordsController, "and tokens" do
  before( :each ) do
    @domain = FactoryBot.create(:domain)
    @admin = FactoryBot.create(:admin)
    @token = AuthToken.new(
      :domain => @domain, :expires_at => 1.hour.since, :user => @admin
    )
  end

  xit "should not be allowed to touch the SOA record" do
    token = FactoryBot.create(:auth_token, :domain => @domain, :user => @admin)
    tokenize_as( token )

    target_soa = @domain.soa_record

    expect {
      put "update_soa", params: {
        :id => target_soa.id, :domain_id => target_soa.domain.id,
        :soa => {
          :primary_ns => 'ns1.example.com', :contact => 'dnsadmin@example.com',
          :refresh => "10800", :retry => "10800", :minimum => "10800", :expire => "604800"
        }
      }, xhr: true
      target_soa.reload
    }.to_not change( target_soa, :contact )
  end

  xit "should not allow new NS records" do
    allow(controller).to receive(:current_token).and_return(@token)

    params = {
      'name' => '',
      'ttl' => '86400',
      'type' => 'NS',
      'content' => 'n3.example.com'
    }

    expect {
      post :create, params: { :domain_id => @domain.id, :record => params }, xhr: true
    }.to_not change( @domain.records, :size )

    response.should_not be_success
    response.code.should == "403"
  end

  xit "should not allow updating NS records" do
    allow(controller).to receive(:current_token).and_return(@token)

    record = FactoryBot.create(:ns, :domain => @domain)

    params = {
      'name' => '',
      'ttl' => '86400',
      'type' => 'NS',
      'content' => 'ns1.somewhereelse.com'
    }

    expect {
      put :update, params: { :id => record.id, :domain_id => @domain.id, :record => params}, xhr: true
      record.reload
    }.to_not change( record, :content )

    response.should_not be_success
    response.code.should == "403"
  end

  xit "should create when allowed" do
    @token.allow_new_records = true
    allow(controller).to receive(:current_token).and_return(@token)

    params = {
      'name' => 'test',
      'ttl' => '86400',
      'type' => 'A',
      'content' => '127.0.0.2'
    }

    expect {
      post :create, params: { :domain_id => @domain.id, :record => params }, xhr: true
    }.to change( @domain.records, :size )

    response.should be_success

    assigns(:domain).should_not be_nil
    assigns(:record).should_not be_nil

    # Ensure the token han been updated
    @token.can_change?( 'test', 'A' ).should be_truthy
    @token.can_remove?( 'test', 'A' ).should be_truthy
  end

  xit "should not create if not allowed" do
    allow(controller).to receive(:current_token).and_return(@token)

    params = {
      'name' => "test",
      'ttl' => "864400",
      'type' => "A",
      'content' => "127.0.0.2"
    }

    expect {
      post :create, params: { :domain_id => @domain.id, :record => params }, xhr: true
    }.to_not change( @domain.records, :size )

    response.should_not be_success
    response.code.should == "403"
  end

  xit "should update when allowed" do
    record = FactoryBot.create(:www, :domain => @domain)
    @token.can_change( record )
    allow(controller).to receive(:current_token).and_return(@token)

    params = {
      'name' => "www",
      'ttl' => "864400",
      'type' => "A",
      'content' => "10.0.1.10"
    }

    expect {
      put :update, params: { :id => record.id, :domain_id => @domain.id, :record => params }, xhr: true
      record.reload
    }.to change( record, :content )

    response.should be_success
    response.should render_template("update")
  end

  xit "should not update if not allowed" do
    record = FactoryBot.create(:www, :domain => @domain)
    allow(controller).to receive(:current_token).and_return(@token)

    params = {
      'name' => "www",
      'ttl' => '',
      'type' => "A",
      'content' => "10.0.1.10"
    }

    expect {
      put :update, params: { :id => record.id, :domain_id => @domain.id, :record => params }, xhr: true
      record.reload
    }.to_not change( record, :content )

    response.should_not be_success
    response.code.should == "403"
  end

  xit "should destroy when allowed" do
    record = FactoryBot.create(:mx, :domain => @domain)
    @token.can_change( record )
    @token.remove_records=( true )
    allow(controller).to receive(:current_token).and_return(@token)

    expect {
      delete :destroy, params: { :domain_id => @domain.id, :id => record.id }
    }.to change( @domain.records, :size ).by(-1)

    response.should be_redirect
    response.should redirect_to( domain_path( @domain ) )
  end

  xit "should not destroy records if not allowed" do
    allow(controller).to receive(:current_token).and_return(@token)
    record = FactoryBot.create(:a, :domain => @domain)

    expect {
      delete :destroy, params: { :domain_id => @domain.id, :id => record.id }
    }.to_not change( @domain.records, :count )

    response.should_not be_success
    response.code.should == "403"
  end

  xit "should not allow tampering with other domains" do
    @token.allow_new_records=( true )
    allow(controller).to receive(:current_token).and_return(@token)

    record = {
      'name' => 'evil',
      'type' => 'A',
      'content' => '127.0.0.3'
    }

    post :create, params: {
      :domain_id => FactoryBot.create(:domain, :name => 'example.net').id,
      :record => record
    }, xhr: true

    response.code.should == "403"
  end
end

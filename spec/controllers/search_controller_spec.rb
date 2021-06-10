require 'spec_helper'

describe SearchController, "for admins" do

  before(:each) do
    #session[:user_id] = FactoryBot.create(:admin).id
    sign_in FactoryBot.create(:admin)

    FactoryBot.create(:domain, :name => 'example.com')
    FactoryBot.create(:domain, :name => 'example.net')
  end

  it "should return results when searched legally" do
    get :results, params: { :q => 'exa' }

    assigns(:results).should_not be_nil
    response.should render_template('search/results')
  end

  it "should handle whitespace in the query" do
    get :results, params: { :q => ' exa ' }

    assigns(:results).should_not be_nil
    response.should render_template('results')
  end

  it "should redirect to the index page when nothing has been searched for" do
    get :results, params: { :q => '' }

    response.should be_redirect
    response.should redirect_to( root_path )
  end

  it "should redirect to the domain page if only one result is found" do
    domain = FactoryBot.create(:domain, :name => 'slave-example.com')

    get :results, params: { :q => 'slave-example.com' }

    response.should be_redirect
    response.should redirect_to( domain_path( domain ) )
  end

end

describe SearchController, "for api clients" do
  before(:each) do
    sign_in(FactoryBot.create(:api_client_user))

    FactoryBot.create(:domain, :name => 'example.com')
    FactoryBot.create(:domain, :name => 'example.net')
  end

  it "should return an empty JSON response for no results" do
    get :results, params: { :q => 'amazon', :format => 'json' }

    assigns(:results).should be_empty

    response.body.should == "[]"
  end

  it "should return a JSON set of results" do
    get :results, params: { :q => 'example', :format => 'json' }

    assigns(:results).should_not be_empty

    json = ActiveSupport::JSON.decode( response.body )
    json.size.should be(2)
    json.first["domain"].keys.should include('id', 'name')
    json.first["domain"]["name"].should match(/example/)
    json.first["domain"]["id"].to_s.should match(/\d+/)
  end
end

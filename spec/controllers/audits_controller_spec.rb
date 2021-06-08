require 'spec_helper'

describe AuditsController do
  let(:user) { FactoryGirl.create(:admin) }
  before(:each) do
    sign_in(user)
  end

  it "should have a search form" do
    get :index

    response.should render_template('audits/index')
  end

  it "should have a domain details page" do
    get :domain, :id => FactoryGirl.create(:domain).id

    assigns(:domain).should_not be_nil

    response.should render_template('audits/domain')
  end

  context "when user is not admin" do
    let(:user) { FactoryGirl.create(:quentin) }

    it "should redirect" do
      get :index

      response.should be_redirect
    end
  end
end

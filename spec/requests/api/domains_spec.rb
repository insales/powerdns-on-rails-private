# frozen_string_literal: true

require 'spec_helper'

RSpec.describe "API v1 domains" do

  let(:domain) { FactoryBot.create(:domain, name: "example.com") }
  let(:api_client) { FactoryBot.create(:api_client) }
  let(:token) { api_client.authentication_token }

  describe "create" do
    let(:domain_name) { FactoryBot.generate(:domain_name) }
    it "works" do
      expect do
        post "/api/v1/domains.json?auth_token=#{token}", params: {
          domain: {
            name: domain_name
          }
        }
        expect(response).to have_http_status(:created)
        expect(response.body).to include(domain_name)
      end.to change(Domain, :count).by(1)
    end
  end

  describe "show" do
    let(:params) { { auth_token: token }}
    subject do
      get "/api/v1/domains/#{domain.id}.json?auth_token=#{token}", params:{}
      expect(response.media_type).to eq 'application/json'
      response
    end

    context "witout valid auth_token" do
      let(:token) { "invalid" }

      it do
        is_expected.not_to be_successful
      end
    end

    it "can find by domain_name" do
      get "/api/v1/domains/id.json", params: params.merge(domain_name: domain.name)
      expect(response).to be_successful
      expect(response.media_type).to eq 'application/json'
    end

    it "works" do
      is_expected.to be_successful
    end
  end

  describe "update" do
  end

  describe "destroy" do
    subject do
      delete "/api/v1/domains/#{domain.id}.json?auth_token=#{token}", params:{}
      response
    end

    it "works" do
      domain
      expect do
        is_expected.to have_http_status(:no_content)
      end.to change(Domain, :count).from(1).to(0)
    end
  end

# Started GET "/api/v1/domains/id.json?auth_token=<token>&domain_name=zoonail.ru" for 78.155.216.235 at 2021-06-09 00:06:58 +0000
# Started GET "/api/v1/domains/161807/records.json?auth_token=<token>"
# Started DELETE "/api/v1/domains/161103/records/3631990.json?auth_token=<token>" for 78.155.216.212 at 2021-06-09 04:53:16 +0000
end

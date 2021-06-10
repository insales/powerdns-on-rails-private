# frozen_string_literal: true

require 'spec_helper'

RSpec.describe "API v1 domain records" do

  let!(:domain) { FactoryBot.create :domain, name: "example.org" }
  let(:record) { FactoryBot.create(:a, domain: domain, content: "10.0.0.1") }
  let(:api_client) { FactoryBot.create(:api_client) }
  let(:token) { api_client.authentication_token }

  describe "index" do
    subject do
      get "/api/v1/domains/#{domain.id}/records.json?auth_token=#{token}", params: {}
      response
    end

    it "returns records" do
      is_expected.to be_successful
      expect(response.media_type).to eq 'application/json'
    end

    context "with invalid token" do
      let(:token) { "lala" }

      it "does not work" do
        is_expected.not_to be_successful
        expect(response.media_type).to eq 'application/json'
      end
    end
  end

  describe "create" do
    it do
      expect do
        post "/api/v1/domains/#{domain.id}/records.json?auth_token=#{token}", params: {
          record: { type: "A", name: "www", content: "85.119.149.174"}
        }
      end.to change(Record, :count).by(1)

      created = Record.last
      expect(created).to be_a(Record::A)
      expect(created.domain).to eq domain
      expect(created.name).to eq "www.example.org"
      expect(created.content).to eq "85.119.149.174"
    end
  end

  describe "show" do
    it "by id" do
      get "/api/v1/domains/#{domain.id}/records/#{record.id}.json?auth_token=#{token}", params: {}
      expect(response).to be_successful
      expect(response.media_type).to eq 'application/json'
      expect(JSON.parse(response.body)).to match(
        "a" => a_hash_including(
          "name" => "example.org",
          "content" => "10.0.0.1"
        )
      )
    end

    it "by name" do
      get "/api/v1/domains/some_domain/records/#{record.id}.json?auth_token=#{token}&domain_name=#{domain.name}",
        params: {}
      expect(response).to be_successful
      expect(response.media_type).to eq 'application/json'
      expect(JSON.parse(response.body)).to match(
        "a" => a_hash_including(
          "name" => "example.org",
          "content" => "10.0.0.1"
        )
      )
    end
  end

  describe "update" do
    it do
      expect do
        patch "/api/v1/domains/some_domain/records/#{record.id}.json?auth_token=#{token}&domain_name=#{domain.name}",
          params: {
            record: {
              name: "www"
            }
          }
        record.reload
      end.to change { record.name }.from("example.org").to("www.example.org")

      expect(response).to be_successful
      expect(response).to have_http_status(:no_content)
    end
  end

  describe "destroy" do
    it do
      record
      expect do
        delete "/api/v1/domains/#{domain.id}/records/#{record.id}.json?auth_token=#{token}", params: {}
        expect(response).to have_http_status(:no_content)
      end.to change(Record, :count).from(2).to(1)
    end
  end

  describe "destroy all" do
    it "deletes all by SOA" do
      record
      expect do
        delete "/api/v1/domains/#{domain.id}/records.json?auth_token=#{token}", params: {}
        expect(response).to have_http_status(:no_content)
      end.to change(Record, :count).from(2).to(1)

      expect(domain.records.first).to be_a(Record::SOA)
    end

    it "for non-existing domain" do
      record
      expect do
        delete "/api/v1/domains/domain/records.json?auth_token=#{token}&domain_name=nonexist.ent", params: {}
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.media_type).to eq 'application/json'
      end.not_to change(Record, :count)
    end
  end
end

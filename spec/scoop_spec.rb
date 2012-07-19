require 'spec_helper'

describe Scoop do

  describe "#get_seed" do
    let(:scoop) { Scoop.new }

    context "seed exists with no donation" do
      let(:stub_response) do
        json_body = {:id => 1, :link => "http://foo.com"}.to_json
        double(Faraday::Response, :status => 200, :body => json_body)
      end

      let(:stub_client) {
        double('client', :get => stub_response)
      }

      before(:each) do
        scoop.stub(:connect).and_return(stub_client)
      end

      it "returns a 200 OK" do
        scoop.get_seed(1)[:status].should eq(200)
      end

      it "returns a json response with a seed" do
        scoop.get_seed(1)[:id].should eq(1)
        scoop.get_seed(1)[:link].should eq("http://foo.com")
      end
    end

    context "seed exists with donation" do
      let(:stub_response) do
        json_body = {:id => 1, :link => "http://foo.com", donation: { amount_cents: 10000, payout_cents: 100 } }.to_json
        double(Faraday::Response, :status => 200, :body => json_body)
      end
      
      let(:stub_client) {
        double('client', :get => stub_response)
      }

      before(:each) do
        scoop.stub(:connect).and_return(stub_client)
      end

      it "returns a 200 OK" do
        scoop.get_seed(1)[:status].should eq(200)
      end

      it "returns a seed with the donation information" do
        scoop.get_seed(1)[:id].should eq(1)
        scoop.get_seed(1)[:link].should eq("http://foo.com")
        scoop.get_seed(1)[:donation][:amount_cents].should eq(10000)
        scoop.get_seed(1)[:donation][:payout_cents].should eq(100)
      end
    end

    context "seed does not exist" do
      let(:stub_bad_response) do
        json_body = {:error => "Seed not found" }.to_json
        double(Faraday::Response, :status => 404, :body => json_body)
      end

      let(:stub_client) {
        double('client', :get => stub_bad_response)
      }

      before(:each) do
        scoop.stub(:connect).and_return(stub_client)
      end

      it "returns a 404 Not Found & error msg" do
        scoop.get_seed(1)[:status].should eq(404)
        scoop.get_seed(1)[:error].should be
      end
    end

  end
end
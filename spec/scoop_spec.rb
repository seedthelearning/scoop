require 'spec_helper'

describe Scoop do

  describe "#get_all_seeds" do
    let(:scoop) { Scoop.new }

    context "there are seeds" do

      context "there are no donations" do
        let(:stub_response) do
          json_body = [ { :id => 1, :link => "http://foo1.com" },
                        { :id => 2, :link => "http://foo2.com" },
                        { :id => 3, :link => "http://foo3.com" }].to_json
          double(Faraday::Response, :status => 200, :body => json_body)
        end

        let(:stub_client) {
          double('client', :get => stub_response)
        }

        before(:each) do
          scoop.stub(:connect).and_return(stub_client)
        end

        it "returns a 200 OK" do
          scoop.get_all_seeds[:status].should eq(200)
        end

        it "returns all the seeds" do
          seeds = scoop.get_all_seeds[:seeds]
          seeds[0][:id].should eq(1)
          seeds[0][:link].should eq("http://foo1.com")
          seeds[1][:id].should eq(2)
          seeds[1][:link].should eq("http://foo2.com")
          seeds[2][:id].should eq(3)
          seeds[2][:link].should eq("http://foo3.com")
        end
      end
      context "there are donations" do
        let(:stub_response) do
          json_body = [ { :id => 1, :link => "http://foo1.com",
                          donation: { amount_cents: 10000,
                                      payout_cents: 100 } },
                        { :id => 2, :link => "http://foo2.com",
                          donation: { amount_cents: 10000,
                                      payout_cents: 100 } },
                        { :id => 3, :link => "http://foo3.com",
                          donation: { amount_cents: 10000,
                                      payout_cents: 100 } }].to_json
          double(Faraday::Response, :status => 200, :body => json_body)
        end

        let(:stub_client) {
          double('client', :get => stub_response)
        }

        before(:each) do
          scoop.stub(:connect).and_return(stub_client)
        end

        it "returns a 200 OK" do
          scoop.get_all_seeds[:status].should eq(200)
        end

        it "returns the seeds" do
          seeds = scoop.get_all_seeds[:seeds]
          seeds[0][:id].should eq(1)
          seeds[0][:link].should eq("http://foo1.com")
          seeds[1][:id].should eq(2)
          seeds[1][:link].should eq("http://foo2.com")
          seeds[2][:id].should eq(3)
          seeds[2][:link].should eq("http://foo3.com")
        end

        it "returns the donations" do
          seeds = scoop.get_all_seeds[:seeds]
          seeds[0][:donation][:amount_cents].should eq(10000)
          seeds[0][:donation][:payout_cents].should eq(100)
          seeds[1][:donation][:amount_cents].should eq(10000)
          seeds[1][:donation][:payout_cents].should eq(100)
          seeds[2][:donation][:amount_cents].should eq(10000)
          seeds[2][:donation][:payout_cents].should eq(100)
        end
      end
    end

    context "there are no seeds" do

      let(:stub_response) do
          json_body = [].to_json
          double(Faraday::Response, :status => 200, :body => json_body)
        end

        let(:stub_client) {
          double('client', :get => stub_response)
        }

        before(:each) do
          scoop.stub(:connect).and_return(stub_client)
        end

      it "returns a 200 OK" do
        scoop.get_all_seeds[:status].should eq(200)
      end

      it "returns an empty list" do
        scoop.get_all_seeds[:seeds].should eq([])
      end
    end
  end

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
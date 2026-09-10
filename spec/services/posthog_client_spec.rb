require "rails_helper"

RSpec.describe PosthogClient do
  before do
    allow(Rails.application.credentials).to receive(:posthog).and_return(api_key: "test_key", host: "test_host")
  end

  describe "singleton pattern" do
    it "does not allow creating new instances" do
      expect { described_class.new }.to raise_error(NoMethodError)
    end

    it "returns the same instance when called multiple times" do
      expect(described_class.instance).to eq(described_class.instance)
    end
  end

  describe ".capture" do
    it "delegates to the client instance" do
      client_double = instance_double(PostHog::Client)
      allow(client_double).to receive(:capture)

      instance = described_class.instance
      allow(instance).to receive(:client).and_return(client_double)

      event_name = "test_event"
      distinct_id = "user-123"
      properties = {test: true}

      described_class.capture(
        distinct_id: distinct_id,
        event: event_name,
        properties: properties
      )

      expect(client_double).to have_received(:capture).with(
        distinct_id: distinct_id,
        event: event_name,
        properties: properties
      )
    end
  end
end

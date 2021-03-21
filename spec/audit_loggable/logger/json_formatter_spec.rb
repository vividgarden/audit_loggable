# frozen_string_literal: true

RSpec.describe AuditLoggable::Logger::JSONFormatter do
  describe "#call" do
    subject { described_class.new.call("INFO", time, nil, message) }

    let!(:time) { Time.now.utc }
    let!(:message) { { key: "value" } }

    it "returns json string with newline character" do
      precision = ::ActiveSupport::JSON::Encoding.time_precision
      expected_string = %({"timestamp":"#{time.iso8601(precision)}","record":{"key":"value"}}\n)

      expect(subject).to eq expected_string
    end
  end
end

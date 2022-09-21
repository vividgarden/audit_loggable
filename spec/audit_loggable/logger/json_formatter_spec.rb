# frozen_string_literal: true

RSpec.describe AuditLoggable::Logger::JSONFormatter do
  describe "#call" do
    subject { described_class.new(timezone: timezone).call("INFO", time, nil, message) }

    let!(:time) { Time.now.utc }
    let!(:message) { { key: "value" } }

    context "when timezone is set to :utc" do
      let!(:timezone) { :utc }

      it "returns json string with newline character" do
        precision = ::ActiveSupport::JSON::Encoding.time_precision
        expected_string = %({"timestamp":"#{time.getutc.iso8601(precision)}","record":{"key":"value"}}\n)

        expect(subject).to eq expected_string
      end
    end

    context "when timezone is set to :local" do
      let!(:timezone) { :local }

      it "returns json string with newline character" do
        precision = ::ActiveSupport::JSON::Encoding.time_precision
        expected_string = %({"timestamp":"#{time.getlocal.iso8601(precision)}","record":{"key":"value"}}\n)

        expect(subject).to eq expected_string
      end
    end
  end
end

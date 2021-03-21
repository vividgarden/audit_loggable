# frozen_string_literal: true

RSpec.describe AuditLoggable::ChangeSet::AttributesRedactor do
  describe "#call" do
    subject { described_class.new(redacted_attributes, changes).call }

    context "when values of changes are single value format" do
      let!(:changes) do
        {
          "status" => 1,
          "title"  => "title value",
          "body"   => "body value",
          "number" => 100
        }
      end

      context "when redacted_attributes are not specified" do
        let!(:redacted_attributes) { [] }

        it "returns a hash same as original changes" do
          expect(subject).to eq(
            {
              "status" => 1,
              "title"  => "title value",
              "body"   => "body value",
              "number" => 100
            }
          )
        end
      end

      context "when redacted_attributes are specified" do
        let!(:redacted_attributes) { %w[title number] }

        it "returns a redacted hash" do
          expect(subject).to eq(
            {
              "status" => 1,
              "title"  => "[REDACTED]",
              "body"   => "body value",
              "number" => "[REDACTED]"
            }
          )
        end
      end
    end

    context "when values of changes are before/after format" do
      let!(:changes) do
        {
          "status" => [nil, 1],
          "title"  => [nil, "title value"],
          "body"   => [nil, "body value"],
          "number" => [nil, 100]
        }
      end

      context "when redacted_attributes are not specified" do
        let!(:redacted_attributes) { [] }

        it "returns a hash same as original changes" do
          expect(subject).to eq(
            {
              "status" => [nil, 1],
              "title"  => [nil, "title value"],
              "body"   => [nil, "body value"],
              "number" => [nil, 100]
            }
          )
        end
      end

      context "when redacted_attributes are specified" do
        let!(:redacted_attributes) { %w[title number] }

        it "returns a redacted hash" do
          expect(subject).to eq(
            {
              "status" => [nil, 1],
              "title"  => ["[REDACTED]", "[REDACTED]"],
              "body"   => [nil, "body value"],
              "number" => ["[REDACTED]", "[REDACTED]"]
            }
          )
        end
      end
    end
  end
end

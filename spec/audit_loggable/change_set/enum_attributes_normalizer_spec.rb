# frozen_string_literal: true

RSpec.describe AuditLoggable::ChangeSet::EnumAttributesNormalizer do
  describe "#call" do
    subject { described_class.new(Post, changes).call }

    context "when values of changes are single value format" do
      context "when changes are not including enum attributes" do
        let!(:changes) do
          {
            "title"  => "title value",
            "body"   => "body value",
            "number" => 100
          }
        end

        it "returns a hash same as original changes" do
          expect(subject).to eq(
            {
              "title"  => "title value",
              "body"   => "body value",
              "number" => 100
            }
          )
        end
      end

      context "when changes are including enum attributes" do
        let!(:changes) do
          {
            "status" => "draft",
            "title"  => "title value",
            "body"   => "body value",
            "number" => 100
          }
        end

        it "returns a normalized hash" do
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
    end

    context "when values of changes are before/after format" do
      context "when changes are not including enum attributes" do
        let!(:changes) do
          {
            "title"  => [nil, "title value"],
            "body"   => [nil, "body value"],
            "number" => [nil, 100]
          }
        end

        it "returns a hash same as original changes" do
          expect(subject).to eq(
            {
              "title"  => [nil, "title value"],
              "body"   => [nil, "body value"],
              "number" => [nil, 100]
            }
          )
        end
      end

      context "when changes are including enum attributes" do
        let!(:changes) do
          {
            "status" => [nil, "draft"],
            "title"  => [nil, "title value"],
            "body"   => [nil, "body value"],
            "number" => [nil, 100]
          }
        end

        it "returns a normalized hash" do
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
    end
  end
end

# frozen_string_literal: true

RSpec.describe AuditLoggable::ChangeSet::AttributesFilter do
  describe "#call" do
    subject { described_class.new(Post, ignored_attributes, changes).call }

    let!(:changes) do
      {
        "id"         => [nil, 1],
        "type"       => [nil, "AwesomePost"],
        "created_at" => [nil, Time.now.utc],
        "updated_at" => [nil, Time.now.utc],
        "created_on" => [nil, Time.now.utc.to_date],
        "updated_on" => [nil, Time.now.utc.to_date],
        "status"     => [nil, "draft"],
        "title"      => [nil, "title value"],
        "body"       => [nil, "body value"],
        "number"     => [nil, 100]
      }
    end

    context "when ignored_attributes are not specified" do
      let!(:ignored_attributes) { [] }

      it "returns a hash filtered by default ignored attributes" do
        expect(subject).to eq(
          {
            "status" => [nil, "draft"],
            "title"  => [nil, "title value"],
            "body"   => [nil, "body value"],
            "number" => [nil, 100]
          }
        )
      end
    end

    context "when ignored_attributes are specified" do
      let!(:ignored_attributes) { %w[title number] }

      it "returns a hash filtered by default ignored attributes and specified ignored attributes" do
        expect(subject).to eq(
          {
            "status" => [nil, "draft"],
            "body"   => [nil, "body value"]
          }
        )
      end
    end
  end
end

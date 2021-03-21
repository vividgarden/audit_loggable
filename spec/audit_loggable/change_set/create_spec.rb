# frozen_string_literal: true

RSpec.describe AuditLoggable::ChangeSet::Create do
  describe "#as_json" do
    subject { described_class.new(model, ignored_attributes: ignored_attributes, redacted_attributes: %w[body]).as_json }

    let!(:model) do
      Post.create(
        type:       "AwesomePost",
        created_at: Time.now.utc,
        updated_at: Time.now.utc,
        created_on: Time.now.utc.to_date,
        updated_on: Time.now.utc.to_date,
        status:     :draft,
        title:      "title value",
        body:       "body value",
        number:     100
      )
    end

    context "when ignored_attributes are not specified" do
      let!(:ignored_attributes) { [] }

      it "returns a hash representing changeset" do
        expect(subject).to eq(
          {
            "user_id" => nil,
            "status"  => 1,
            "title"   => "title value",
            "body"    => "[REDACTED]",
            "number"  => 100
          }
        )
      end
    end

    context "when ignored_attributes are specified" do
      let!(:ignored_attributes) { %w[title number] }

      it "returns a hash representing changeset that except ignored attributes" do
        expect(subject).to eq(
          {
            "user_id" => nil,
            "status"  => 1,
            "body"    => "[REDACTED]"
          }
        )
      end
    end
  end
end

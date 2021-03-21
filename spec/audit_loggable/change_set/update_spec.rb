# frozen_string_literal: true

RSpec.describe AuditLoggable::ChangeSet::Update do
  describe "#as_json" do
    subject { described_class.new(model, ignored_attributes: ignored_attributes, redacted_attributes: %w[body]).as_json }

    let!(:model) do
      Post.create(
        type:       "NormalPost",
        created_at: Time.now.utc,
        updated_at: Time.now.utc,
        created_on: Time.now.utc.to_date,
        updated_on: Time.now.utc.to_date,
        status:     :draft,
        title:      "title value",
        body:       "body value",
        number:     100
      ).tap do |p|
        p.update(
          type:       "AwesomePost",
          created_at: Time.now.utc + 1,
          updated_at: Time.now.utc + 1,
          created_on: Time.now.utc.to_date + 1,
          updated_on: Time.now.utc.to_date + 1,
          status:     :published,
          title:      "updated title value",
          body:       "updated body value",
          number:     200
        )
      end
    end

    context "when ignored_attributes are not specified" do
      let!(:ignored_attributes) { [] }

      it "returns a hash representing changeset" do
        expect(subject).to eq(
          {
            "status" => [1, 2],
            "title"  => ["title value", "updated title value"],
            "body"   => ["[REDACTED]", "[REDACTED]"],
            "number" => [100, 200]
          }
        )
      end
    end

    context "when ignored_attributes are specified" do
      let!(:ignored_attributes) { %w[title number] }

      it "returns a hash representing changeset that except ignored attributes" do
        expect(subject).to eq(
          {
            "status" => [1, 2],
            "body"   => ["[REDACTED]", "[REDACTED]"]
          }
        )
      end
    end
  end

  describe "#empty?" do
    subject { described_class.new(model, ignored_attributes: ignored_attributes).empty? }

    let!(:model) do
      Post.create(
        type:       "NormalPost",
        created_at: Time.now.utc,
        updated_at: Time.now.utc,
        created_on: Time.now.utc.to_date,
        updated_on: Time.now.utc.to_date,
        status:     :draft,
        title:      "title value",
        body:       "body value",
        number:     100
      ).tap do |p|
        p.update(
          type:       "AwesomePost",
          created_at: Time.now.utc + 1,
          updated_at: Time.now.utc + 1,
          created_on: Time.now.utc.to_date + 1,
          updated_on: Time.now.utc.to_date + 1,
          status:     :published,
          title:      "updated title value",
          body:       "updated body value",
          number:     200
        )
      end
    end

    context "when all changed attributes are not ignored" do
      let!(:ignored_attributes) { [] }

      it { is_expected.to eq false }
    end

    context "when some changed attributes are ignored" do
      let!(:ignored_attributes) { %w[title number] }

      it { is_expected.to eq false }
    end

    context "when all changed attributes are ignored" do
      let!(:ignored_attributes) { %w[status title body number] }

      it { is_expected.to eq true }
    end
  end
end

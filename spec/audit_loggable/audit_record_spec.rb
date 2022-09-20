# frozen_string_literal: true

RSpec.describe AuditLoggable::AuditRecord do
  describe "#as_json" do
    subject { audit_record.as_json }

    let!(:action) { %i[create update destroy].sample }
    let!(:remote_address) { ["127.0.0.1", nil].sample }
    let!(:request_uuid) { [SecureRandom.uuid, nil].sample }

    context "when user is setted" do
      let!(:audit_record) do
        described_class.new(
          Post.new(id: 1),
          User.new(id: 2),
          action,
          { "foo" => [1, 2], "bar" => %w[before after] },
          remote_address,
          request_uuid
        )
      end

      it "returns a hash representing audit record that user is setted" do
        expect(subject).to eq(
          {
            "auditable"      => { "id" => 1, "type" => "Post" },
            "user"           => { "id" => 2, "type" => "User" },
            "action"         => action.to_s,
            "changes"        => %({"foo":[1,2],"bar":["before","after"]}),
            "remote_address" => remote_address,
            "request_uuid"   => request_uuid
          }
        )
      end
    end

    context "when user is not setted" do
      let!(:audit_record) do
        described_class.new(
          Post.new(id: 1),
          nil,
          action,
          { "foo" => [1, 2], "bar" => %w[before after] },
          remote_address,
          request_uuid
        )
      end

      it "returns a hash representing audit record that user is nil" do
        expect(subject).to eq(
          {
            "auditable"      => { "id" => 1, "type" => "Post" },
            "user"           => nil,
            "action"         => action.to_s,
            "changes"        => %({"foo":[1,2],"bar":["before","after"]}),
            "remote_address" => remote_address,
            "request_uuid"   => request_uuid
          }
        )
      end
    end
  end
end

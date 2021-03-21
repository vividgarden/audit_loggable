# frozen_string_literal: true

RSpec.describe AuditLoggable::Extension::Callbacks do
  describe "#after_create" do
    let!(:callbacks) { described_class.new(except: ignored, redacted: redacted) }
    let!(:ignored) { :password }
    let!(:redacted) { :email }
    let!(:model) do
      User.create!(name: "dummy user", email: "dummy@example.com", password: "dummy password").tap do |u|
        u.singleton_class.attr_internal :audit_loggable_audit_record_set
      end
    end

    it "should store audit record to set" do
      dummy_user = instance_double(User)
      expect(::AuditLoggable::Store).to receive(:current_user).and_return(dummy_user)
      dummy_ip = "192.168.0.1"
      expect(::AuditLoggable::Store).to receive(:current_remote_address).and_return(dummy_ip)
      dummy_uuid = SecureRandom.uuid
      expect(::AuditLoggable::Store).to receive(:current_request_uuid).and_return(dummy_uuid)

      dummy_changeset = instance_double(::AuditLoggable::ChangeSet::Create)
      expect(::AuditLoggable::ChangeSet::Create)
        .to receive(:new)
              .with(model,
                    ignored_attributes: Array(ignored).map(&:to_s),
                    redacted_attributes: Array(redacted).map(&:to_s))
              .and_return(dummy_changeset)
      dummy_audit_record = instance_double(::AuditLoggable::AuditRecord)
      expect(::AuditLoggable::AuditRecord)
        .to receive(:new)
              .with(model, dummy_user, :create, dummy_changeset, dummy_ip, dummy_uuid)
              .and_return(dummy_audit_record)

      callbacks.after_create(model)

      expect(model.audit_loggable_audit_record_set).to be_one
      expect(model.audit_loggable_audit_record_set.to_a).to contain_exactly(dummy_audit_record)
    end
  end

  describe "#after_update" do
    let!(:callbacks) { described_class.new(except: ignored, redacted: redacted) }
    let!(:ignored) { :password }
    let!(:redacted) { :email }
    let!(:model) do
      User.create!(name: "dummy user", email: "dummy@example.com", password: "dummy password").tap do |u|
        u.reload
        u.singleton_class.attr_internal :audit_loggable_audit_record_set
        u.update!(name: "dummy updated user", email: "dummy-updated@example.com", password: "dummy updated password")
      end
    end

    context "when changes are empty" do
      before { model.clear_changes_information }

      it "does not store audit record to set" do
        expect(::AuditLoggable::ChangeSet::Update)
          .to receive(:new)
                .with(model,
                      ignored_attributes: Array(ignored).map(&:to_s),
                      redacted_attributes: Array(redacted).map(&:to_s))
                .and_call_original
        expect(::AuditLoggable::AuditRecord).not_to receive(:new)

        callbacks.after_update(model)

        expect(model.audit_loggable_audit_record_set).to be_blank
      end
    end

    context "when changes are present" do
      it "should store audit record to set" do
        dummy_user = instance_double(User)
        expect(::AuditLoggable::Store).to receive(:current_user).and_return(dummy_user)
        dummy_ip = "192.168.0.1"
        expect(::AuditLoggable::Store).to receive(:current_remote_address).and_return(dummy_ip)
        dummy_uuid = SecureRandom.uuid
        expect(::AuditLoggable::Store).to receive(:current_request_uuid).and_return(dummy_uuid)

        dummy_changeset = instance_double(::AuditLoggable::ChangeSet::Update)
        expect(::AuditLoggable::ChangeSet::Update)
          .to receive(:new)
                .with(model,
                      ignored_attributes: Array(ignored).map(&:to_s),
                      redacted_attributes: Array(redacted).map(&:to_s))
                .and_return(dummy_changeset)
        dummy_audit_record = instance_double(::AuditLoggable::AuditRecord)
        expect(::AuditLoggable::AuditRecord)
          .to receive(:new)
                .with(model, dummy_user, :update, dummy_changeset, dummy_ip, dummy_uuid)
                .and_return(dummy_audit_record)

        callbacks.after_update(model)

        expect(model.audit_loggable_audit_record_set).to be_one
        expect(model.audit_loggable_audit_record_set.to_a).to contain_exactly(dummy_audit_record)
      end
    end
  end

  describe "#after_destroy" do
    let!(:callbacks) { described_class.new(except: ignored, redacted: redacted) }
    let!(:ignored) { :password }
    let!(:redacted) { :email }
    let!(:model) do
      User.create!(name: "dummy user", email: "dummy@example.com", password: "dummy password").tap do |u|
        u.reload
        u.singleton_class.attr_internal :audit_loggable_audit_record_set
        u.destroy!
      end
    end

    it "should store audit record to set" do
      dummy_user = instance_double(User)
      expect(::AuditLoggable::Store).to receive(:current_user).and_return(dummy_user)
      dummy_ip = "192.168.0.1"
      expect(::AuditLoggable::Store).to receive(:current_remote_address).and_return(dummy_ip)
      dummy_uuid = SecureRandom.uuid
      expect(::AuditLoggable::Store).to receive(:current_request_uuid).and_return(dummy_uuid)

      dummy_changeset = instance_double(::AuditLoggable::ChangeSet::Destroy)
      expect(::AuditLoggable::ChangeSet::Destroy)
        .to receive(:new)
              .with(model,
                    ignored_attributes: Array(ignored).map(&:to_s),
                    redacted_attributes: Array(redacted).map(&:to_s))
              .and_return(dummy_changeset)
      dummy_audit_record = instance_double(::AuditLoggable::AuditRecord)
      expect(::AuditLoggable::AuditRecord)
        .to receive(:new)
              .with(model, dummy_user, :destroy, dummy_changeset, dummy_ip, dummy_uuid)
              .and_return(dummy_audit_record)

      callbacks.after_destroy(model)

      expect(model.audit_loggable_audit_record_set).to be_one
      expect(model.audit_loggable_audit_record_set.to_a).to contain_exactly(dummy_audit_record)
    end
  end

  describe "#after_commit" do
    let!(:callbacks) { described_class.new(except: :password, redacted: :email) }
    let!(:model) do
      User.create!(name: "dummy user", email: "dummy@example.com", password: "dummy password").tap do |u|
        u.singleton_class.attr_internal :audit_loggable_audit_record_set
      end
    end

    context "when audit_loggable_audit_record_set is nil" do
      it "does not flush audit record set" do
        expect_any_instance_of(::AuditLoggable::AuditRecordSet).not_to receive(:flush)

        callbacks.after_commit(model)
      end
    end

    context "when audit_loggable_audit_record_set is empty" do
      it "does not flush audit record set" do
        dummy_audit_record_set = instance_double(::AuditLoggable::AuditRecordSet)
        expect(dummy_audit_record_set).to receive(:empty?).and_return(true)
        expect(dummy_audit_record_set).not_to receive(:flush)
        model.audit_loggable_audit_record_set = dummy_audit_record_set

        callbacks.after_commit(model)
      end
    end

    context "when audit_loggable_audit_record_set is not empty" do
      before do
        callbacks.after_create(model)
        model.update!(name: "dummy updated user", email: "dummy-updated@example.com", password: "dummy updated password")
        callbacks.after_update(model)
      end

      it "should flush audit record set" do
        expect(model.audit_loggable_audit_record_set).to be_many
        expect(model.audit_loggable_audit_record_set).to receive(:flush).and_call_original

        callbacks.after_commit(model)

        expect(model.audit_loggable_audit_record_set).to be_blank
      end
    end
  end

  describe "#after_rollback" do
    let!(:callbacks) { described_class.new(except: :password, redacted: :email) }
    let!(:model) do
      User.create!(name: "dummy user", email: "dummy@example.com", password: "dummy password").tap do |u|
        u.singleton_class.attr_internal :audit_loggable_audit_record_set
      end
    end

    context "when audit_loggable_audit_record_set is nil" do
      it "does not clear audit record set" do
        expect_any_instance_of(::AuditLoggable::AuditRecordSet).not_to receive(:clear)

        callbacks.after_rollback(model)
      end
    end

    context "when audit_loggable_audit_record_set is empty" do
      it "does not clear audit record set" do
        dummy_audit_record_set = instance_double(::AuditLoggable::AuditRecordSet)
        expect(dummy_audit_record_set).to receive(:empty?).and_return(true)
        expect(dummy_audit_record_set).not_to receive(:clear)
        model.audit_loggable_audit_record_set = dummy_audit_record_set

        callbacks.after_commit(model)
      end
    end

    context "when audit_loggable_audit_record_set is not empty" do
      before do
        callbacks.after_create(model)
        model.update!(name: "dummy updated user", email: "dummy-updated@example.com", password: "dummy updated password")
        callbacks.after_update(model)
      end

      it "should clear audit record set" do
        expect(model.audit_loggable_audit_record_set).to be_many
        expect(model.audit_loggable_audit_record_set).to receive(:clear).and_call_original

        callbacks.after_rollback(model)

        expect(model.audit_loggable_audit_record_set).to be_empty
      end
    end
  end
end

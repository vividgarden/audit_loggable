# frozen_string_literal: true

RSpec.describe AuditLoggable::Extension do
  describe ".log_audit" do
    let!(:model_class) do
      Class.new(ApplicationRecord) do
        self.table_name = "posts"

        extend ::AuditLoggable::Extension
      end
    end

    it "has one after_create callbak" do
      callbacks =
        model_class
          .__callbacks[:create]
          .select { |c| c.kind == :after && c.filter.is_a?(::AuditLoggable::Extension::Callbacks) }
      expect(callbacks).to be_none

      model_class.log_audit

      callbacks =
        model_class
          .__callbacks[:create]
          .select { |c| c.kind == :after && c.filter.is_a?(::AuditLoggable::Extension::Callbacks) }
      expect(callbacks).to be_one
    end

    it "has one after_update callbak" do
      callbacks =
        model_class
          .__callbacks[:update]
          .select { |c| c.kind == :after && c.filter.is_a?(::AuditLoggable::Extension::Callbacks) }
      expect(callbacks).to be_none

      model_class.log_audit

      callbacks =
        model_class
          .__callbacks[:update]
          .select { |c| c.kind == :after && c.filter.is_a?(::AuditLoggable::Extension::Callbacks) }
      expect(callbacks).to be_one
    end

    it "has one after_destroy callbak" do
      callbacks =
        model_class
          .__callbacks[:destroy]
          .select { |c| c.kind == :after && c.filter.is_a?(::AuditLoggable::Extension::Callbacks) }
      expect(callbacks).to be_none

      model_class.log_audit

      callbacks =
        model_class
          .__callbacks[:destroy]
          .select { |c| c.kind == :after && c.filter.is_a?(::AuditLoggable::Extension::Callbacks) }
      expect(callbacks).to be_one
    end

    it "has one after_commit callbak" do
      callbacks =
        model_class
          .__callbacks[:commit]
          .select { |c| c.kind == :after && c.filter.is_a?(::AuditLoggable::Extension::Callbacks) }
      expect(callbacks).to be_none

      model_class.log_audit

      callbacks =
        model_class
          .__callbacks[:commit]
          .select { |c| c.kind == :after && c.filter.is_a?(::AuditLoggable::Extension::Callbacks) }
      expect(callbacks).to be_one
    end

    it "has one after_rollback callbak" do
      callbacks =
        model_class
          .__callbacks[:rollback]
          .select { |c| c.kind == :after && c.filter.is_a?(::AuditLoggable::Extension::Callbacks) }
      expect(callbacks).to be_none

      model_class.log_audit

      callbacks =
        model_class
          .__callbacks[:rollback]
          .select { |c| c.kind == :after && c.filter.is_a?(::AuditLoggable::Extension::Callbacks) }
      expect(callbacks).to be_one
    end

    it "has audit_loggable_audit_record_set accessor" do
      expect(model_class.instance_methods).not_to include :audit_loggable_audit_record_set
      expect(model_class.instance_methods).not_to include :audit_loggable_audit_record_set=

      model_class.log_audit

      expect(model_class.instance_methods).to include :audit_loggable_audit_record_set
      expect(model_class.instance_methods).to include :audit_loggable_audit_record_set=
    end

    it "should create AuditLoggable::Extension::Callbacks instance" do
      callbacks = instance_double(::AuditLoggable::Extension)
      expect(::AuditLoggable::Extension::Callbacks).to receive(:new).with(except: :title, redacted: :body).and_return(callbacks)

      expect(model_class).to receive(:after_create).with(callbacks)
      expect(model_class).to receive(:after_update).with(callbacks)
      expect(model_class).to receive(:after_destroy).with(callbacks)
      expect(model_class).to receive(:after_commit).with(callbacks)
      expect(model_class).to receive(:after_rollback).with(callbacks)

      model_class.log_audit(except: :title, redacted: :body)
    end
  end
end

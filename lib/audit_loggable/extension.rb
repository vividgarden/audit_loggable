# frozen_string_literal: true

module AuditLoggable
  module Extension
    def log_audit(except: [], redacted: [])
      self.class_eval do
        attr_internal :audit_loggable_audit_record_set

        callbacks = Callbacks.new(except: except, redacted: redacted)
        after_create   callbacks
        after_update   callbacks
        after_destroy  callbacks
        after_rollback callbacks
        after_commit   callbacks
      end
    end

    class Callbacks
      def initialize(except: [], redacted: [])
        @ignored_attributes = ::Array.wrap(except).map(&:to_s)
        @redacted_attributes = ::Array.wrap(redacted).map(&:to_s)
      end

      def after_create(model)
        changeset = build_changeset_for_create(model)

        audit_record = build_audit_record(model, :create, changeset)
        add_audit_record(model, audit_record)
      end

      def after_update(model)
        changeset = build_changeset_for_update(model)
        return if changeset.blank?

        audit_record = build_audit_record(model, :update, changeset)
        add_audit_record(model, audit_record)
      end

      def after_destroy(model)
        changeset = build_changeset_for_destroy(model)

        audit_record = build_audit_record(model, :destroy, changeset)
        add_audit_record(model, audit_record)
      end

      def after_rollback(model)
        return if model.audit_loggable_audit_record_set.blank?

        clear_audit_record_set(model)
      end

      def after_commit(model)
        return if model.audit_loggable_audit_record_set.blank?

        persist_audit_record_set(model)
      end

      private

      attr_reader :ignored_attributes, :redacted_attributes

      def build_changeset_for_create(model)
        ChangeSet::Create.new(model, ignored_attributes: ignored_attributes, redacted_attributes: redacted_attributes)
      end

      def build_changeset_for_update(model)
        ChangeSet::Update.new(model, ignored_attributes: ignored_attributes, redacted_attributes: redacted_attributes)
      end

      def build_changeset_for_destroy(model)
        ChangeSet::Destroy.new(model, ignored_attributes: ignored_attributes, redacted_attributes: redacted_attributes)
      end

      def build_audit_record(model, action, changeset)
        user = Store.current_user
        address = Store.current_remote_address
        uuid = Store.current_request_uuid

        AuditRecord.new(model, user, action, changeset, address, uuid)
      end

      def add_audit_record(model, audit_record)
        model.audit_loggable_audit_record_set ||= AuditRecordSet.new
        model.audit_loggable_audit_record_set << audit_record
      end

      def clear_audit_record_set(model)
        model.audit_loggable_audit_record_set.clear
      end

      def persist_audit_record_set(model)
        model.audit_loggable_audit_record_set.flush
      end
    end
  end
end

# frozen_string_literal: true

module AuditLoggable
  class AuditRecord
    def initialize(auditable, user, action, changeset, remote_address, request_uuid)
      @auditable = auditable
      @user = user
      @action = action
      @changeset = changeset
      @remote_address = remote_address
      @request_uuid = request_uuid
    end

    def as_json(*)
      {
        auditable: { id: auditable.id, type: auditable.class.polymorphic_name },
        user: user ? { id: user.id, type: user.class.polymorphic_name } : nil,
        action: action,
        changes: changeset.to_json, # serialize to JSON string
        remote_address: remote_address,
        request_uuid: request_uuid
      }
    end

    private

    attr_reader :auditable, :user, :action, :changeset, :remote_address, :request_uuid
  end
end

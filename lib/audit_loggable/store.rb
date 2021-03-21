# frozen_string_literal: true

require "active_support/current_attributes"

module AuditLoggable
  class Store < ::ActiveSupport::CurrentAttributes
    attribute :current_controller, :current_user, :current_remote_address, :current_request_uuid

    def current_user
      super&.yield_self do |user|
        if user.is_a?(::Proc) || user.is_a?(::Method) || user.respond_to?(:call)
          user.call
        else
          user
        end
      end
    end
  end
end

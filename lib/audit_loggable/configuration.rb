# frozen_string_literal: true

module AuditLoggable
  class Configuration
    attr_accessor :audit_log_path, :audit_log_shift_age, :audit_log_shift_size, :audit_log_shift_period_suffix,
                  :auditing_enabled, :audit_log_timezone

    def initialize
      self.auditing_enabled = true
      self.audit_log_shift_age = 0
      self.audit_log_shift_size = 1024 * 1024
      self.audit_log_shift_period_suffix = "%Y%m%d"
      self.audit_log_timezone = :local
    end
  end
end

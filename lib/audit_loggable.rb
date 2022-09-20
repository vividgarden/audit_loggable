# frozen_string_literal: true

require "active_support"
require "active_support/core_ext/object/blank"
require "active_support/core_ext/object/json"
require "active_support/core_ext/module/attr_internal"
require "active_support/core_ext/module/delegation"

require "audit_loggable/version"
require "audit_loggable/configuration"
require "audit_loggable/logger"
require "audit_loggable/store"
require "audit_loggable/change_set"
require "audit_loggable/audit_record"
require "audit_loggable/audit_record_set"
require "audit_loggable/sweeper"
require "audit_loggable/extension"

module AuditLoggable
  class << self
    attr_reader :logger

    delegate :audit_log_path, :audit_log_shift_age, :audit_log_shift_size, :audit_log_shift_period_suffix,
             :auditing_enabled, :audit_log_timezone,
             to: :configuration

    def configure
      yield configuration
      initialize_logger

      self
    end

    private

    attr_reader :configuration

    def initialize_logger
      @logger = Logger.new(
        self.audit_log_path,
        shift_age:           self.audit_log_shift_age,
        shift_size:          self.audit_log_shift_size,
        shift_period_suffix: self.audit_log_shift_period_suffix,
        timezone:            self.audit_log_timezone
      )
    end
  end

  @configuration = Configuration.new
end

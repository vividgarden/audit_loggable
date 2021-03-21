# frozen_string_literal: true

require "logger"

module AuditLoggable
  class Logger
    class JSONFormatter < ::Logger::Formatter
      def call(_severity, time, _progname, message)
        h = { timestamp: time, record: message }
        "#{h.to_json}\n"
      end
    end

    class NoHeaderLogDevice < ::Logger::LogDevice
      private

      def add_log_header(*)
        # Suppress header output when creating a log file
      end
    end

    class InternalLogger < ::Logger
      def initialize(logdev, shift_age:, shift_size:, shift_period_suffix:)
        super(nil, level: :info, formatter: JSONFormatter.new)

        return unless logdev

        @logdev =
          NoHeaderLogDevice.new(logdev,
                                shift_age: shift_age,
                                shift_size: shift_size,
                                shift_period_suffix: shift_period_suffix)
      end
    end

    def initialize(*args, **kwargs)
      @logger = InternalLogger.new(*args, **kwargs)
    end

    def log(audit_record_set)
      return unless ::AuditLoggable.auditing_enabled

      audit_record_set.each do |audit_record|
        @logger.info(audit_record)
      end
    end
  end
end

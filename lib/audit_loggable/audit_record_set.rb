# frozen_string_literal: true

module AuditLoggable
  class AuditRecordSet
    include ::Enumerable

    delegate :empty?, to: :set

    def initialize
      clear
    end

    def <<(audit_record)
      set << audit_record
      self
    end

    def clear
      @set = []
      self
    end

    def each(&block)
      return to_enum unless block

      set.each(&block)
      self
    end

    def flush
      ::AuditLoggable.logger.log(set)
      clear
    end

    private

    attr_reader :set
  end
end

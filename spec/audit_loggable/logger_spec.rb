# frozen_string_literal: true

RSpec.describe AuditLoggable::Logger do
  describe "#log" do
    let!(:logger) do
      described_class.new(
        ::AuditLoggable.audit_log_path,
        shift_age:           ::AuditLoggable.audit_log_shift_age,
        shift_size:          ::AuditLoggable.audit_log_shift_size,
        shift_period_suffix: ::AuditLoggable.audit_log_shift_period_suffix,
        timezone:            ::AuditLoggable.audit_log_timezone
      )
    end

    context "when AuditLoggable.auditing_enabled is false" do
      before { allow(::AuditLoggable).to receive(:auditing_enabled).and_return(false) }

      it "does not log any audit records" do
        internal_logger = logger.instance_variable_get(:@logger)

        audit_record1 = instance_double(::AuditLoggable::AuditRecord)
        audit_record2 = instance_double(::AuditLoggable::AuditRecord)
        expect(internal_logger).not_to receive(:info).with(audit_record1)
        expect(internal_logger).not_to receive(:info).with(audit_record2)

        expect { logger.log([audit_record1, audit_record2]) }.not_to raise_error
      end
    end

    context "when AuditLoggable.auditing_enabled is true" do
      before { allow(::AuditLoggable).to receive(:auditing_enabled).and_return(true) }

      it "logs each audit records" do
        internal_logger = logger.instance_variable_get(:@logger)

        audit_record1 = instance_double(::AuditLoggable::AuditRecord)
        audit_record2 = instance_double(::AuditLoggable::AuditRecord)
        expect(internal_logger).to receive(:info).with(audit_record1)
        expect(internal_logger).to receive(:info).with(audit_record2)

        expect { logger.log([audit_record1, audit_record2]) }.not_to raise_error
      end
    end
  end
end

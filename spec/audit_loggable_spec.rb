# frozen_string_literal: true

RSpec.describe AuditLoggable do
  it "has a version number" do
    expect(AuditLoggable::VERSION).not_to be nil
  end
end

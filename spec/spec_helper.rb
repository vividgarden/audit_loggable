# frozen_string_literal: true

ENV["RAILS_ENV"] = "test"
require "bundler/setup"
require_relative "dummy/config/environment"
require "audit_loggable"

AuditLoggable.configure do |config|
  config.audit_log_path = File.expand_path("../audits.log", __dir__)
end

require_relative "support/active_record/schema"

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end

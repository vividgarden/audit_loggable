# frozen_string_literal: true

lib = File.expand_path("lib", __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "audit_loggable/version"

Gem::Specification.new do |spec|
  spec.name          = "audit_loggable"
  spec.version       = AuditLoggable::VERSION
  spec.authors       = ["Yuji Hanamura"]
  spec.email         = ["yuji.developer@gmail.com"]

  spec.summary       = "Log changes to your models"
  spec.description   = spec.summary
  spec.homepage      = "https://github.com/vividgarden/audit_loggable"
  spec.license       = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata["allowed_push_host"] = "TODO: Set to 'http://mygemserver.com'"

    spec.metadata["homepage_uri"] = spec.homepage
    spec.metadata["source_code_uri"] = spec.homepage
    spec.metadata["changelog_uri"] = "https://github.com/vividgarden/audit_loggable/blob/main/CHANGELOG.md"
  else
    raise "RubyGems 2.0 or newer is required to protect against " \
      "public gem pushes."
  end

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.required_ruby_version = ">= 2.5"

  spec.add_dependency "activerecord",  ">= 6.0"
  spec.add_dependency "activesupport", ">= 6.0"

  spec.add_development_dependency "appraisal", ">= 2.3.0"
  spec.add_development_dependency "bundler",   ">= 1.17"
  spec.add_development_dependency "rails",     ">= 6.0"
  spec.add_development_dependency "rake",      ">= 10.0"
  spec.add_development_dependency "rspec",     "~> 3.10"
  spec.add_development_dependency "sqlite3",   "~> 1.4"
end

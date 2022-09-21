# AuditLoggable

[![Gem Version](https://badge.fury.io/rb/audit_loggable.svg)](https://badge.fury.io/rb/audit_loggable)
[![Build](https://github.com/vividgarden/audit_loggable/actions/workflows/ruby.yml/badge.svg)](https://github.com/vividgarden/audit_loggable/actions/workflows/ruby.yml)

AuditLoggable is a Rails plugin gem that logs changes to your models. AuditLoggable can also record who made those changes.  
AuditLoggable is inspired by [Audited](https://github.com/collectiveidea/audited). However AuditLoggable logs to a JSONL file instead of RDB table.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'audit_loggable'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install audit_loggable

## Usage

### Configuration
``` ruby
# config/initializers/audit_loggable.rb
AuditLoggable.configure do |config|
  if Rails.env.test?
    config.auditing_enabled = false
  end
  config.audit_log_path = Rails.root.join("log", "audits.log")
  config.audit_log_shift_age = "daily"
end
```

Options
| Name                            | Type              | Description                                                        | Default   |
|:--------------------------------|:------------------|:-------------------------------------------------------------------|:----------|
| `auditing_enabled`              | Boolean           | Switch to record audit log.                                        | `true`    |
| `audit_log_path`                | String            | Path of audit log file.                                            | `nil`     |
| `audit_log_shift_age`           | Integer or String | Same as `shift_age` option of `Logger` class of stdlib.            | `0`       |
| `audit_log_shift_size`          | Integer           | Same as `shift_size` option of `Logger` class of stdlib.           | `1048576` |
| `audit_log_shift_period_suffix` | String            | Same as `shift_period_suffix` options of `Logger` class of stdlib. | `%Y%m%d`  |
| `audit_log_timezone`            | Enum              | The timezone of timestamp. Any value of `:local` or `:utc`.        | `local`  |

### Extend your model by `AuditLoggable::Extension`
``` ruby
class ApplicationRecord < ActiveRecord::Base
  extend AuditLoggable::Extension
end
```

Active `AuditLoggable` in your model
``` ruby
class Post < ApplicationRecord
  log_audit
end
```

if you need to except columns by audit logging, specify `except` option as follow:
``` ruby
class Post < ApplicationRecord
  log_audit except: %w[foo bar]
end
```

if you need to record changes but not their values by audit logging, specify `redacted` option as follow:
``` ruby
class Post < ApplicationRecord
  log_audit redacted: %w[foo bar]
end
```

### Extend your controller by `AuditLoggable::Sweeper` to track request info (e.g. current user)
``` ruby
class ApplicationController < ActionController::Base
  around_action AuditLoggable::Sweeper.new(current_user_methods: %i[current_user])
end
```


## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/vividgarden/audit_loggable. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/vividgarden/audit_loggable/blob/main/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the AuditLoggable project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/vividgarden/audit_loggable/blob/main/CODE_OF_CONDUCT.md).

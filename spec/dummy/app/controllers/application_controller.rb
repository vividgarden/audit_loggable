# frozen_string_literal: true

class ApplicationController < ActionController::Base
  around_action ::AuditLoggable::Sweeper.new(
    current_user_methods: %i[
      current_user
      current_custom_user
    ]
  )
end

# frozen_string_literal: true

module AuditLoggable
  class Sweeper
    STORED_DATA = {
      current_remote_address: :remote_ip,
      current_request_uuid:   :request_uuid,
      current_user:           :current_user
    }.freeze

    def initialize(current_user_methods: %i[current_user])
      @current_user_methods = ::Array.wrap(current_user_methods).map(&:to_sym)
    end

    def around(controller, &block)
      Store.set({ current_controller: controller }) do
        Store.set(
          STORED_DATA
            .each_pair
            .with_object({}) { |(k, m), h| h[k] = __send__(m) },
          &block
        )
      end
    end

    private

    attr_reader :current_user_methods

    delegate :request,   to: :controller, private: true, allow_nil: true
    delegate :remote_ip, to: :request,    private: true, allow_nil: true
    delegate :uuid,      to: :request,    private: true, allow_nil: true, prefix: true

    def current_user
      lambda do
        current_user_methods
          .lazy.map { |m| controller.__send__(m) if controller.respond_to?(m, true) }
          .find(&:present?)
      end
    end

    def controller
      Store.current_controller
    end
  end
end

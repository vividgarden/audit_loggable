# frozen_string_literal: true

RSpec.describe AuditLoggable::Sweeper do
  describe PostsController do
    it "has one around_action callbak" do
      callbacks = described_class.__callbacks[:process_action].select { |c| c.kind == :around && c.filter.is_a?(::AuditLoggable::Sweeper) }
      expect(callbacks).to be_one
    end
  end

  describe "#around" do
    let!(:user) { User.create!(name: "audit user") }
    let!(:uuid) { SecureRandom.uuid }
    let!(:ip_address) { "192.168.0.1" }

    context "when current user methods are not found" do
      let!(:sweeper) do
        ::AuditLoggable::Sweeper.new(
          current_user_methods: %i[nope]
        )
      end

      it "should not store current_user" do
        controller = instance_double(PostsController)
        request = instance_double(ActionDispatch::Request)
        expect(request).to receive(:remote_ip).and_return(ip_address)
        expect(request).to receive(:uuid).and_return(uuid)
        expect(controller).to receive(:request).and_return(request).twice
        allow(controller).to receive(:current_user).and_return(user)
        expect(::AuditLoggable::Store).to receive(:set).with({ current_controller: controller }).and_call_original
        expect(::AuditLoggable::Store)
          .to receive(:set)
                .with(
                  {
                    current_remote_address: ip_address,
                    current_request_uuid:   uuid,
                    current_user:           be_a(Proc).and(satisfy { |p| p.call.nil? })
                  }
                ).and_call_original
        expect { |b| sweeper.around(controller, &b) }.to yield_control
      end
    end

    context "when current user methods are found" do
      let!(:sweeper) do
        ::AuditLoggable::Sweeper.new(
          current_user_methods: %i[
            current_user
            current_custom_user
          ]
        )
      end

      it "should store current user using current_user method" do
        controller = instance_double(PostsController)
        request = instance_double(ActionDispatch::Request)
        expect(request).to receive(:remote_ip).and_return(ip_address)
        expect(request).to receive(:uuid).and_return(uuid)
        expect(controller).to receive(:request).and_return(request).twice
        expect(controller).to receive(:current_user).and_return(user)
        allow(controller).to receive(:current_custom_user).and_return(nil)
        expect(::AuditLoggable::Store).to receive(:set).with({ current_controller: controller }).and_call_original
        expect(::AuditLoggable::Store)
          .to receive(:set)
                .with(
                  {
                    current_remote_address: ip_address,
                    current_request_uuid:   uuid,
                    current_user:           be_a(Proc).and(satisfy { |p| p.call == user })
                  }
                ).and_call_original
        expect { |b| sweeper.around(controller, &b) }.to yield_control
      end

      it "should store current user using current_custom_user method" do
        controller = instance_double(PostsController)
        request = instance_double(ActionDispatch::Request)
        expect(request).to receive(:remote_ip).and_return(ip_address)
        expect(request).to receive(:uuid).and_return(uuid)
        expect(controller).to receive(:request).and_return(request).twice
        allow(controller).to receive(:current_user).and_return(nil)
        expect(controller).to receive(:current_custom_user).and_return(user)
        expect(::AuditLoggable::Store).to receive(:set).with({ current_controller: controller }).and_call_original
        expect(::AuditLoggable::Store)
          .to receive(:set)
                .with(
                  {
                    current_remote_address: ip_address,
                    current_request_uuid:   uuid,
                    current_user:           be_a(Proc).and(satisfy { |p| p.call == user })
                  }
                ).and_call_original
        expect { |b| sweeper.around(controller, &b) }.to yield_control
      end
    end
  end
end

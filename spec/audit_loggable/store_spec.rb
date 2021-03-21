# frozen_string_literal: true

RSpec.describe AuditLoggable::Store do
  before { described_class.reset }

  describe "#current_user" do
    subject { described_class.current_user }

    context "when a Proc object is stored" do
      before do
        stored_object = proc { "stored Proc object" }
        described_class.current_user = stored_object
      end

      it { is_expected.to eq "stored Proc object" }
    end

    context "when a lambda object is stored" do
      before do
        stored_object = lambda { "stored lambda object" }
        described_class.current_user = stored_object
      end

      it { is_expected.to eq "stored lambda object" }
    end

    context "when a Method object is stored" do
      before do
        klass = Class.new do
          def foo
            "stored Method object"
          end
        end
        stored_object = klass.new.method(:foo)

        described_class.current_user = stored_object
      end

      it { is_expected.to eq "stored Method object" }
    end

    context "when a callable object is stored" do
      before do
        klass = Class.new do
          def call
            "stored callable object"
          end
        end
        stored_object = klass.new

        described_class.current_user = stored_object
      end

      it { is_expected.to eq "stored callable object" }
    end

    context "when an other object is stored" do
      before { described_class.current_user = "stored object" }

      it { is_expected.to eq "stored object" }
    end

    context "when any object is not stored" do
      it { is_expected.to be_nil }
    end
  end
end

# frozen_string_literal: true

RSpec.describe AuditLoggable::AuditRecordSet do
  describe "#<<" do
    it "returns self and stores object" do
      record_set = described_class.new
      expected_record_set = record_set

      expect(record_set << "foo").to equal expected_record_set
      expect(record_set << "bar").to equal expected_record_set
      expect(record_set.instance_variable_get(:@set)).to eq %w[foo bar]
    end
  end

  describe "#clear" do
    it "returns self and clears stored object" do
      record_set = described_class.new
      record_set << "foo" << "bar"
      expected_record_set = record_set

      expect(record_set.clear).to equal expected_record_set
      expect(record_set.instance_variable_get(:@set)).to be_empty
    end
  end

  describe "#empty?" do
    subject { record_set.empty? }

    let!(:record_set) { described_class.new }

    context "when objects are stored" do
      before { record_set << "foo" }

      it { is_expected.to eq false }
    end

    context "when objects are not stored" do
      it { is_expected.to eq true }
    end
  end

  describe "#each" do
    context "with block" do
      it "enumerates with stored objects" do
        record_set = described_class.new
        record_set << "foo" << "bar"
        expected_record_set = record_set

        expect { |b| record_set.each(&b) }.to yield_successive_args("foo", "bar")
        expect(record_set.each {}).to equal expected_record_set
      end
    end

    context "without block" do
      it "returns enumerator" do
        record_set = described_class.new
        record_set << "foo" << "bar"

        expect(record_set.each).to be_a Enumerator
        expect(record_set.each.to_a).to eq %w[foo bar]
      end
    end
  end

  describe "#flush" do
    it "logs stored objects, clears stored objects, and returns self" do
      record_set = described_class.new
      record_set << "foo" << "bar"
      expected_record_set = record_set

      expect(AuditLoggable.logger).to receive(:log).with(%w[foo bar])
      expect(record_set.flush).to equal expected_record_set
      expect(record_set).to be_empty
    end
  end
end

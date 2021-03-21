# frozen_string_literal: true

module AuditLoggable
  module ChangeSet
    class AttributesFilter
      IGNORED_ATTRIBUTES = %w[created_at updated_at created_on updated_on].freeze

      def initialize(klass, ignored_attributes, changes)
        @klass = klass
        @ignored_attributes = ignored_attributes
        @changes = changes
      end

      def call
        @changes
          .except(
            @klass.primary_key,
            @klass.inheritance_column,
            @klass.locking_column,
            *@ignored_attributes,
            *IGNORED_ATTRIBUTES
          )
      end
    end

    class EnumAttributesNormalizer
      def initialize(klass, changes)
        @klass = klass
        @changes = changes
      end

      def call
        @klass.defined_enums.each_pair.with_object(@changes.dup) do |(name, values), changes|
          next unless changes.key?(name)

          changes[name] =
            if changes[name].is_a? ::Array
              changes[name].map { |v| values[v] }
            else
              changes[name] = values[changes[name]]
            end
        end
      end
    end

    class AttributesRedactor
      REDACTED_VALUE = "[REDACTED]"

      def initialize(redacted_attributes, changes)
        @redacted_attributes = redacted_attributes
        @changes = changes
      end

      def call
        @redacted_attributes.each.with_object(@changes.dup) do |name, changes|
          next unless changes.key?(name)

          changes[name] =
            if changes[name].is_a? ::Array
              ::Array.new(changes[name].size, REDACTED_VALUE)
            else
              REDACTED_VALUE
            end
        end
      end
    end

    class Base
      def initialize(model, changes_method:, ignored_attributes: [], redacted_attributes: [])
        klass = model.class
        @changes =
          model
            .public_send(changes_method)
            .yield_self { |changes| AttributesFilter.new(klass, ignored_attributes, changes).call }
            .yield_self { |changes| EnumAttributesNormalizer.new(klass, changes).call }
            .yield_self { |changes| AttributesRedactor.new(redacted_attributes, changes).call }
      end

      delegate :as_json, :empty?, to: :changes

      private

      attr_reader :changes
    end

    class Create < Base
      def initialize(*args, **kwargs)
        super(*args, changes_method: :attributes, **kwargs)
      end
    end

    class Update < Base
      def initialize(*args, **kwargs)
        super(*args, changes_method: :previous_changes, **kwargs)
      end
    end

    class Destroy < Base
      def initialize(*args, **kwargs)
        super(*args, changes_method: :attributes, **kwargs)
      end
    end
  end
end

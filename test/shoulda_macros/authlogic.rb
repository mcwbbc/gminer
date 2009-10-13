module Authlogic
  module ShouldaMacros
    class Test::Unit::TestCase
      def self.should_be_authentic
        klass = described_type
        should "acts as authentic" do
          assert klass.new.respond_to?(:password=)
          assert klass.new.respond_to?(:valid_password?)
        end
      end
    end
  end
end

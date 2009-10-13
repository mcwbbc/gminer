class ActionController::TestCase
  def self.should_have_helper_method(*helper_methods)
    klass = described_type
    klass_methods = klass.master_helper_module.instance_methods.map(&:to_s)
    helper_methods.each do |helper_method|
      should "make #{helper_method} available to views" do
        assert klass_methods.include?(helper_method.to_s)
      end
    end
  end
end

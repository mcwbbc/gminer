require 'test_helper'

class UserTest < ActiveSupport::TestCase

  context "using authlogic" do
    setup do
      activate_authlogic
    end
  
    should_be_authentic
  
    context "serialize roles" do
      setup do
        @user = User.generate
      end
    
      should "default to an empty array" do
        assert_equal [], @user.roles
      end
    
      should "allow saving and retrieving roles array" do
        @user.roles = ["soldier", "sailor", "spy"]
        @user.save
        user_id = @user.id
        user2 = User.find(user_id)
        assert_equal ["soldier", "sailor", "spy"], user2.roles
      end
    
      should "not allow non-array data" do
        assert_raise ActiveRecord::SerializationTypeMismatch do
          @user.roles = "snakeskin shoes"
          @user.save
        end
      end
    end
  
    should_callback :make_default_roles, :before_validation_on_create
    
    
    should_allow_mass_assignment_of :password, :password_confirmation, :email
    should_not_allow_mass_assignment_of :crypted_password, :password_salt, :persistence_token, :login_count, :last_request_at, :last_login_at,
      :current_login_at, :last_login_ip, :current_login_ip, :roles, :created_at, :updated_at, :id
  
    context "#deliver_password_reset_instructions!" do
      setup do
        @user = User.generate!
        stub(Notifier).password_reset_instructions{ nil }
      end
    
      should "reset the perishable token" do
        mock(@user).reset_perishable_token!
        @user.deliver_password_reset_instructions!
      end
    
      should "send the reset mail" do
        mock(Notifier).deliver_password_reset_instructions(@user)
        @user.deliver_password_reset_instructions!
      end
    end
  
    context "#deliver_activation_instructions!" do
  setup do
    @user = User.generate!
    stub(Notifier).deliver_activation_instructions
  end

  should "reset the perishable token" do
    @user.expects(:reset_perishable_token!)
    @user.deliver_activation_instructions!
  end

  should "send the reset mail" do
    mock(Notifier).deliver_activation_instructions(@user)
    @user.deliver_activation_instructions!
  end
end

context "#deliver_welcome_email!" do
  setup do
    @user = User.generate!
    stub(Notifier).deliver_welcome_email
  end

  should "reset the perishable token" do
    mock(@user).reset_perishable_token!
    @user.deliver_welcome_email!
  end

  should "send the reset mail" do
    mock(Notifier).deliver_welcome_email(@user)
    @user.deliver_welcome_email!
  end
end

context "#has_no_credentials?" do
  setup do
    @user = User.generate
  end

  should "return true if password has not been set" do
    @user.crypted_password = nil
    assert @user.has_no_credentials?
  end

  should "return false if password has been set" do
    @user.crypted_password = "ABCD"
    assert !@user.has_no_credentials?
  end
end

context "#signup!" do
  setup do
    @user = User.generate
    stub(@user).save_without_session_maintenance{ true }
  end

  should "set the email" do
    @user.signup!(:user => {:email => "joe@example.com"})
    assert_equal "joe@example.com", @user.email
  end

  should "save the user without session maintenance" do
    mock(@user).save_without_session_maintenance
    @user.signup!(:user => {:email => "joe@example.com"})
  end
end

context "#activate!" do
  setup do
    @user = User.generate
    stub(@user).save{ true }
  end

  context "without parameters" do
    should "activate the user" do
      @user.activate!
      assert @user.active
    end
  
    should "save the user" do
      mock(@user).save
      @user.activate!
    end
  end

  context "with parameters" do
    should "activate the user" do
      @user.activate!(:user => {:password => "sekrit", :password_confirmation => "sekrit"})
      assert @user.active
    end
  
    should "set the password" do
      @user.activate!(:user => {:password => "sekrit", :password_confirmation => "sekrit"})
      assert_equal "sekrit", @user.password
    end

    should "set the password confirmation" do
      @user.activate!(:user => {:password => "sekrit", :password_confirmation => "sekrit"})
      assert_equal "sekrit", @user.password_confirmation
    end

    should "save the user" do
      @user.expects(:save).once
      @user.activate!(:user => {:password => "sekrit", :password_confirmation => "sekrit"})
    end
  end
end


    context "#admin?" do
      setup do
        @user = User.generate
      end
    
      should "return true if the user has the admin role" do
        @user.add_role("admin")
        assert @user.admin?
      end
    
      should "return false if the user does not have the admin role" do
        @user.clear_roles
        assert !@user.admin?
      end
    end
  
    context "#has_role?" do
      setup do
        @user = User.generate
      end
    
      should "return true if the user has the specified role" do
        @user.add_role("saint")
        assert @user.has_role?("saint")
      end
    
      should "return false if the user does not have the specified role" do
        @user.clear_roles
        assert !@user.has_role?("saint")
      end
    end

    context "#add_role" do
      should "add the specified role" do
        @user = User.generate
        @user.add_role("wombat")
        assert @user.roles.include?("wombat")
      end
    end
  
    context "#remove_role" do
      should "remove the specified role" do
        @user = User.generate
        @user.add_role("omnivore")
        @user.remove_role("omnivore")
        assert !@user.roles.include?("omnivore")
      end
    end
  
    context "#clear_roles" do
      should "have no roles after clearing" do
        @user = User.generate
        @user.add_role("cat")
        @user.add_role("dog")
        @user.add_role("goldfish")
        @user.clear_roles
        assert_equal [], @user.roles
      end
    end
  
    context "#kaboom!" do
      should "blow up predictably" do
        assert_raise NameError do
          @user = User.generate!
          @user.kaboom!
        end
      end
    end
  end 
end

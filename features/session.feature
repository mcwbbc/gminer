Feature: Session handling
  In order to use the site
  As a registered user
  I need to be able to signin and signout

  Background:
    Given the confirmed user "minimal@example.com" exists

  Scenario Outline: Logging in
    Given I am on the signin page
    When I fill in "user_email" with "<email>"
    And I fill in "user_password" with "<password>"
    And I press "Sign in"
    Then I should <action>
    Examples:
      |         email       |  password   |              action             |
      | minimal@example.com |  test1234   | see "Signed in successfully"    |
      | bad@example.com     |  password   | see "Invalid email or password" |

  Scenario: Logging out
    Given I am signed in
    When I go to the signout
    Then I should see "Signed out successfully"

  Scenario: Edit user information
    Given I am signed in
    When I go to the edit user
    Then I should see "Edit User"



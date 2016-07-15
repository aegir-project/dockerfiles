Feature: Aegir UI
  In order to easily manage my server
  As an aegir user
  I need an awesome web UI

  @api
  Scenario: Log in and poke around.
    Given I am on the homepage
    Then I should see "Access denied. You must log in to view this page."
    # When I run drush "@hostmaster hosting-tasks"
    Then I am logged in as a user with the "administrator" role
    And I am on the homepage
    And I should see "aegir.docker"
    Then I should see "Sites"
    And I should see "Task queue"

    # Confirm all tasks verified.
    When I click "Tasks"
    Then I should see "aegir.docker" in the ".hosting-success" element

    # Not sure why this fails
    # And I should see "hostmaster" in the ".hosting-success" element
    # And I should see "database" in the ".hosting-success" element

    # Platforms Page
    When I click "Platforms"
    Then I should see "hostmaster"
    Then I should see "drupal"
    Then I should see "aegir.docker"

    # Platforms table
    Then I should see "Platform"
    Then I should see "Release"
    Then I should see "Server"
    Then I should see "Verified"
    Then I should see "Sites"


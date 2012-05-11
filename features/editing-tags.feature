Feature: Editing tags
  In order that editors can assign tags to a mapping
  I want to be able to create, rename and destroy tags

  Scenario: List all the tags
    Given many tags exist
    When I visit the tags list
    Then I should see all the tags in the list

  Scenario: Create a tag
    When I visit the new tag form
      And I enter the tag details into the form
    Then the tag should be created
      And I should see the tag in the list
      And the API should be updated to show the tag

  Scenario: Rename a tag
    Given a tag exists
    When I rename the tag
    Then the tag should be renamed
      And I should see the tag in the list
      And the API should be updated to show the tag

  @javascript
  Scenario: Destroy a tag
    Given the tag example exists
      And mappings exist with the tag example
    When I destroy the tag
    Then the tag should be deleted
      And the tag should not appear in the list
      And mappings should not exist with the tag
      And the API should not show the tag
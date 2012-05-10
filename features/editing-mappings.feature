Feature: Editing mappings
  In order to ensure a smooth transition between websites
  I want to be able to create, retrieve, update and delete mappings
  So that people can be redirected to the new resource

  Scenario: Retrieve a mapping from the API
    Given a mapping exists
    When I request a mapping from the API
    Then I should be able to see the information about the mapping

  Scenario: Browse the mappings list
    Given many mappings exist
    When I visit the mappings list
    Then I should see mappings

  Scenario: Filter mappings by tag
    Given many mappings exist
      And mappings exist with the tag example
    When I visit the mappings list
    Then I should see the correct tags in the list
    When I filter by the tag example
    Then I should only see mappings with the tag example in the list

  @javascript
  Scenario: Create a mapping
    When I visit the new mappings form
      And I enter the mapping details into the form
    Then the mapping should be created
      And I should see the mapping in the list
      And the API should be updated to show the mapping
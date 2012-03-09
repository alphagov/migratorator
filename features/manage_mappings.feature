Feature: Manage mappings
  In order to ensure a smooth transition between websites
  I want to be able to create, retrieve, update and delete mappings
  So that people can be redirected to the new resource

  Scenario: Retrieve a mapping from the API
    Given a mapping exists
    When I request a mapping from the API
    Then I should be able to see the information about the mapping
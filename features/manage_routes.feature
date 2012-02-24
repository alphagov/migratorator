Feature: Manage routes
  In order to ensure a smooth transition between websites
  I want to be able to create, retrieve, update and delete routes
  So that people can be redirected to the new resource

  Scenario: Retrieve a route from the API
    Given a route exists
    When I request a route from the API
    Then I should be able to see the information about the route
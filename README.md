# Migratorator

A Web site and browser tools to assist migrating a Web site to another domain.

The Web site collects mappings, pairs of URLs with a redirection or error status.
A mapping may be annotated with notes, related links and collected using tags.

# API and Tools

The mappings are available from the Web site as JSON, allowing tools to be built upon the API:

* router — infrastructure to log web site usage and redirect links
* mod_rewite - export the mappings in Apache mod_rewite format
* badge - a warning to be applied to old pages to forewarn of an impending migration
* validator - report on links to the old site to be updated

## Testing

Migratorator is written in Rails and uses RSpec and Cucumber for testing. To run the tests:

    rake cucumber
    rake spec

## Colophon

Migratorator is being developed by [http://digital.cabinetoffice.gov.uk/](The Government Digital Service) to move content onto [http://www.gov.uk](gov.uk).

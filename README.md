IMPORTANT: If you took a copy of this repo before 27th November 2012, you will have to reset your branch to our new master or make a fresh clone as we rewrote the history. Many apologies for the inconvenience.

# Migratorator

A Web site and browser tools to assist migrating a Web site to another domain.

The Web site collects mappings: pairs of URLs with a redirection or error status.
A mapping may be annotated with notes, related links and collected using tags.

# Setup

Included in db/migratorator_development is bson data for Mongo. You can import this into your migratorator_development mongo db by going to migratorator root directory and typing:

    mongorestore -d migratorator_development ./db/migratorator_development

# API and Tools

The mappings are available from the Web site as JSON, allowing tools to be built upon the API:

* browser - compare old and new pages, side-by-side
* router — infrastructure to log web site usage and redirect links
* mod_rewite - export the mappings in Apache mod_rewite format
* badge - a warning to be applied to old pages to forewarn of an impending migration
* validator - report on links to the old site to be updated

## Testing

Migratorator is written in Rails and uses RSpec and Cucumber for testing. To run the tests:

    govuk_setenv migratorator bundle exec rake spec RAILS_ENV=test
    govuk_setenv migratorator bundle exec rake cucumber RAILS_ENV=test

## Colophon

Migratorator is being developed by the [Government Digital Service](http://digital.cabinetoffice.gov.uk/) to move content onto [GOV.UK](https://www.gov.uk/).

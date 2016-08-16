# Rails 3.x

These notes describe behavior specific to the Rails 2.x environment. Unless
otherwise specified the approach in the main documentation applies.

## Installation

Add the `postageapp` gem to your Gemfile:

    gem 'postageapp'

Then from the Rails project's root run:

    bundle install
    script/rails generate postageapp --api-key PROJECT_API_KEY

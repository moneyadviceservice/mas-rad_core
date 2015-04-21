# mas-rad_core

This project contains a Rails Engine with shared code used for the Retirement
Adviser Directory.

![Build Status](https://travis-ci.org/moneyadviceservice/mas-rad_core.svg?branch=master)

## Prerequisites

* [Git](http://git-scm.com)
* [Ruby 2.2.2](http://www.ruby-lang.org/en)
* [Rubygems 2.2.2](http://rubygems.org)
* [Bundler](http://bundler.io)
* [PostgreSQL](http://www.postgresql.org/)
* [Elasticsearch >= 1.2](https://www.elastic.co/products/elasticsearch)

## Setup

Clone the repository:

```sh
$ git clone https://github.com/moneyadviceservice/mas-rad_core.git
```

Make sure all dependencies are available to the application:

```sh
$ bundle install
```

Make sure PostgreSQL is running.

Setup the database:

```sh
$ cp spec/dummy/config/database.example.yml spec/dummy/config/database.yml
```
Be sure to remove or modify the `username` attribute.

```sh
$ bundle exec rake db:create \
  && bundle exec rake db:migrate \
  && bundle exec rake db:schema:load
```

**NOTE** `db:schema:load` loads into both the test and development databases.
But `db:migrate` does not.

## Running the Tests

To run the Ruby tests:

```sh
$ bundle exec rspec
```

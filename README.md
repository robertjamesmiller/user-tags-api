# user-tags-api

[![Build Status](https://travis-ci.org/robertjamesmiller/user-tags-api.svg?branch=master)](https://travis-ci.org/robertjamesmiller/user-tags-api)

## How to run, configure, and deploy this webapp
 
### Install and start Redis

* brew install redis
* redis-server /usr/local/etc/redis.conf

### Install and start MySQL

* brew install mysql
* start it
* login is as root: mysql -u root -p
  * CREATE SCHEMA user_tags;
  * CREATE USER 'webapp'@'localhost' IDENTIFIED BY 'rails';
  * GRANT ALL ON user_tags.* TO 'webapp'@'localhost';
  * CREATE SCHEMA test_user_tags; 
  * GRANT ALL ON test_user_tags.* TO 'webapp'@'localhost';

### Install Ruby and Bundler

* Install RVM
* rvm install ruby-2.2.3
* rvm use ruby-2.2.3ruby 
* gem install bundler

### Git clone this project, then

* cd user-tags-api
* bundle install
* rake db:migrate && rake db:migrate RAILS_ENV=test
* bundle exec rspec
* rails server

## REST API with Basic Authentication

### POST /api/v1/users(.json)

 Create a user.

**Parameters:** 

 - email (String) (*required*) : Your email. 

### PUT /api/v1/users/:id/add\_tags(.json)

 Add tags to a user

**Parameters:** 

 - id (Integer) (*required*) : User id. 
 - tags ([String]) (*required*) : List of tags. 

### PUT /api/v1/users/:id/remove\_tags(.json)

 Remove tags from a user

**Parameters:** 

 - id (Integer) (*required*) : User id. 
 - tags ([String]) (*required*) : List of tags. 

### GET /api/v1/users/:id(.json)

 Return a user with their tags

**Parameters:** 

 - id (Integer) (*required*) : User id. 

### POST /api/v1/users/search(.json)

 Search users by tags

**Parameters:** 

 - tags ([String]) (*required*) : List of tags. 
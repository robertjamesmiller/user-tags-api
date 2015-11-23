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
* rvm use ruby-2.2.3
* gem install bundler

### Git clone this project, then

* cd user-tags-api
* bundle install
* rake db:migrate && rake db:migrate RAILS_ENV=test
* [bundle exec rspec](https://travis-ci.org/robertjamesmiller/user-tags-api)
* rails server
 * Configure your client or webapp to use http://localhost:3000/api/v1/users/

## Design Choices

* Use Rails and ActiveRecord to persist Users to support future features like a user's profile, credentials, and transactions.
* Use Redis to persist the associations between Users and Tags because its [SINTER command](http://redis.io/commands/SINTER) will query and return the intersection of all the given sets of user ids associated to tags, and do so very quickly even for tags that have a million users. 
* Use Grape to provide a lightweight REST API with basic authentication.
  * A client or another webapp can communicate with this webapp and make changes to all of the data.
* Use RSpec to test Rails models, Redis commands, and REST API requests.
* Throughput and response time:
  * REST API only returns minimal number of fields.
  * Redis handles user/tag associations and queries.

### Potential future features

* Provide devices (e.g., smart watches) with a user specific token with which to authenticate requests and authorize them to a limited set of actions specific to their profile or their friends' profiles.
* Use Redis to store Rails sessions and REST API user tokens, both with strategically configured expirations.
* [Provide a web user interface using features from Bootstrap and AngularJS (e.g., ngResource, angular-ui-grid, X-CSRF-Tokens).](https://github.com/sparc-request/sparc-request/pull/219/files?diff=unified)
  * Develop a standard Rails controller that responds to JSON requests that will be rendered by AngularJS.
* If a user is deleted from MySQL, remove all references of that user from Redis.
* Restrict the length of an individual tag to prevent Redis performance issues.
  
## REST API with Basic Authentication

### POST /api/v1/users(.json)

 Create a user.

**Parameters:** 

 - email (String) (*required*) : Your email. 
 
**Returns:**

 - id
 - email

### PUT /api/v1/users/:id/add\_tags(.json)

 Add tags to a user

**Parameters:** 

 - id (Integer) (*required*) : User id. 
 - tags ([String]) (*required*) : List of tags. 
 
**Returns:**

 - nothing

### PUT /api/v1/users/:id/remove\_tags(.json)

 Remove tags from a user

**Parameters:** 

 - id (Integer) (*required*) : User id. 
 - tags ([String]) (*required*) : List of tags. 

**Returns:**

 - nothing

### GET /api/v1/users/:id(.json)

 Return a user with their tags

**Parameters:** 

 - id (Integer) (*required*) : User id. 

**Returns:**

 - id
 - email
 - tags ([String])

### POST /api/v1/users/search(.json)

 Search users by tags they would be associated with. For example, find all users tagged as both "funny" and "cyclist". 

**Parameters:** 

 - tags ([String]) (*required*) : List of tags. 
 
**Returns:**

 - users ([ { id , email } ])
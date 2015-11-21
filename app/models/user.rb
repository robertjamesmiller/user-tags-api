class User < ActiveRecord::Base
  
  validates :email, format: { with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i, message: "is not valid" }
  validates :email, uniqueness: true
end

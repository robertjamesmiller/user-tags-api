class User < ActiveRecord::Base
  
  validates :email, format: { with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i, message: "is not valid" }
  validates :email, uniqueness: true
  
  # @TODO on delete, in redis, remove user:id:tags and tags:tag:user_id
  
  
  def add_tags(tag_array)
    tags = Tags.new(tag_array)        
    tags.add_user(self)
  end
  
  def remove_tags(tag_array)
    tags = Tags.new(tag_array)        
    tags.remove_user(self)
  end
  
  def tags
    $redis.smembers(user_tags_key)
  end
  
  def user_tags_key
    "users:#{self.id}:tags"
  end

end

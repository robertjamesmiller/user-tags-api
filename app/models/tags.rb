class Tags
  
  def initialize( tag_array )
    @tag_array = tag_array
  end
  
  def add_user(user)
    if (@tag_array.length > 0)
      # atomic transaction
      $redis.multi do
        $redis.sadd(user.user_tags_key, @tag_array)
        @tag_array.each do |tag|
          $redis.sadd(tag_users_key(tag), user.id)
        end
      end
    end
  end
  
  def remove_user(user)
    if (@tag_array.length > 0)
      # atomic transaction
      $redis.multi do
        $redis.srem(user.user_tags_key, @tag_array)
        @tag_array.each do |tag|
          $redis.srem(tag_users_key(tag), user.id)
        end
      end
    end
  end
  
  def users
    if (@tag_array.length > 0)
      tag_keys = []
      @tag_array.each do |tag|
        tag_keys << tag_users_key(tag)
      end
      $redis.sinter(tag_keys)
    else
      []
    end
  end
  
  private
  
  def tag_users_key(tag)
    "tags:#{tag}:users"
  end
  
end
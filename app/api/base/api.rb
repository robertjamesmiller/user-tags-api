module Base
  class API < Grape::API
    version 'v1', using: :path
    format :json
    prefix :api
    
    # verify client's username/password
    http_basic do |username, password|
      { 'client' => 'authenticate_me' }[username] == password
    end
    
    resource :users do
      
      desc 'Create a user.'
      params do
        requires :email, type: String, desc: 'Your email.' #, regexp: /.+@.+/
      end
      post do   
        user = User.new({email: params[:email]})
        if user.save # @TODO: replace with Grape::Entity
          present :id, user.id
          present :email, user.email
        else
          error!(user.errors, :unprocessable_entity)
        end 
      end
      
      desc 'Add tags to a user'
      params do
        requires :id, type: Integer, desc: 'User id.'
        requires :tags, type: Array[String], desc: 'List of tags.'
      end
      put ':id/add_tags' do
        user = User.where(id: params[:id]).first()
        if !user
          error!("User not found for id=#{params[:id]}", :not_found )
        else
          user.add_tags(params[:tags])
          body false 
        end
      end
      
      desc 'Remove tags from a user'
      params do
        requires :id, type: Integer, desc: 'User id.'
        requires :tags, type: Array[String], desc: 'List of tags.'
      end
      put ':id/remove_tags' do
        user = User.where(id: params[:id]).first()
        if !user
          error!("User not found for id=#{params[:id]}", :not_found )
        else
          user.remove_tags(params[:tags])
          body false 
        end
      end
      
      desc 'Return a user with their tags'
      params do
        requires :id, type: Integer, desc: 'User id.'
      end
      get ':id' do
        user = User.where(id: params[:id]).first()
        if !user
          error!("User not found for id=#{params[:id]}", :not_found )
        else # @TODO: replace with Grape::Entity
          present :id, user.id
          present :email, user.email
          present :tags, user.tags
        end
      end
      
      desc 'Search users by tags'
      params do
        requires :tags, type: Array[String], desc: 'List of tags.'
      end
      post '/search' do
        tags = Tags.new(params[:tags])
        User.find(tags.users)
        # @TODO: respond with a status of 200 instead of 201
        # @TODO: don't return created_at and updated_at
      end
    end
  end
end
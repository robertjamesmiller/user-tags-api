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
        if user.save
          user
        else
          error!(user.errors, :unprocessable_entity)
        end 
      end
    
    end
  end
end
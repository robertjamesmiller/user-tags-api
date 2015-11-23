require 'rails_helper'

RSpec.describe Base::API, type: :request do

  before :each do
    # clear redis before each test
    $redis.flushdb
    
    @env ||= {}
    @env['CONTENT_TYPE']= "application/json"
  end
      
  describe 'basic authenticated requests' do
    before :each do
      @env['HTTP_AUTHORIZATION'] = ActionController::HttpAuthentication::Basic.encode_credentials('client', 'authenticate_me')
    end
    
    describe 'to create user' do
      it 'should create and return a new user' do
        expect {
          post '/api/v1/users/', '{"email" : "test@test.com"}', @env
          expect(response.status).to eq(201)
          
          created_user = User.where(:email =>"test@test.com").first
          expect(JSON.parse(response.body)).to include("id" => created_user.id, "email" => "test@test.com")
        }.to change(User, :count).by(1)
      end
      
      it 'should return validation error for empty email and 422' do
        expect {
          post '/api/v1/users/', '{"email" : ""}', @env
          expect(response.status).to eq(422)          
          expect(JSON.parse(response.body)).to eq({"email"=>["is not valid"]})
        }.to change(User, :count).by(0)
      end
    end
    
    describe 'to associate tags to user' do
      before :each do
        @user = User.new
        @user.email = "test@test.com"
        @user.save      
      end
      
      it 'should add two tags to a user' do
          expect(@user.tags).to eq([]) 
          tags_param = { :tags => ["friendly","adventurous"] }
          put "/api/v1/users/#{@user.id}/add_tags", tags_param.to_json, @env
          expect(response.status).to eq(204)
          expect(response.body).to eq("")
          expect(@user.tags).to include("friendly","adventurous")
      end
      
      it 'should add zero tags to a user because tag list is empty' do
          expect(@user.tags).to eq([]) 
          tags_param = { :tags => [] }
          put "/api/v1/users/#{@user.id}/add_tags", tags_param.to_json, @env
          expect(response.status).to eq(204)
          expect(response.body).to eq("")
          expect(@user.tags).to eq([])
      end
      
      it 'should add two tags to a user even if one is duplicated' do
          expect(@user.tags).to eq([]) 
          tags_param = { :tags => ["friendly","adventurous","friendly"] }
          put "/api/v1/users/#{@user.id}/add_tags", tags_param.to_json, @env
          expect(response.status).to eq(204)
          expect(response.body).to eq("")
          expect(@user.tags).to include("friendly","adventurous")
      end
      
      it 'should return 404 for user id not found' do
          tags_param = { :tags => ["friendly","adventurous","friendly"] }
          put "/api/v1/users/345345/add_tags", tags_param.to_json, @env
          expect(response.status).to eq(404)
          expect(JSON.parse(response.body)).to include("error" =>"User not found for id=345345")
      end
    end
    
    describe 'to disassociate tags from user' do
      before :each do
        @user = User.new
        @user.email = "test@test.com"
        @user.save  
        
        @user.add_tags(["friendly","adventurous"])    
      end
      
      it 'should remove two tags from a user' do
        tags_param = { :tags => ["friendly","adventurous"] }
        put "/api/v1/users/#{@user.id}/remove_tags", tags_param.to_json, @env
        expect(response.status).to eq(204)
        expect(response.body).to eq("")
        expect(@user.tags).to eq([])
      end
      
      it 'should remove zero tags from a user because tag list is empty' do
        tags_param = { :tags => [] }
        put "/api/v1/users/#{@user.id}/remove_tags", tags_param.to_json, @env
        expect(response.status).to eq(204)
        expect(response.body).to eq("")
        expect(@user.tags).to include("friendly", "adventurous")
      end
      
      it 'should remove two tags from a user even if one is duplicated' do
        tags_param = { :tags => ["friendly","adventurous","friendly"] }
        put "/api/v1/users/#{@user.id}/remove_tags", tags_param.to_json, @env
        expect(response.status).to eq(204)
        expect(response.body).to eq("")
        expect(@user.tags).to eq([])
      end
      
      it 'should remove only one tag from a user' do
        tags_param = { :tags => ["friendly"] }
        put "/api/v1/users/#{@user.id}/remove_tags", tags_param.to_json, @env
        expect(response.status).to eq(204)
        expect(response.body).to eq("")
        expect(@user.tags).to eq(["adventurous"])
      end
      
      it 'should return 404 for user id not found' do
        tags_param = { :tags => ["friendly","adventurous","friendly"] }
        put "/api/v1/users/345345/remove_tags", tags_param.to_json, @env
        expect(response.status).to eq(404)
        expect(JSON.parse(response.body)).to include("error" =>"User not found for id=345345")
      end
    end
    
    describe 'to show user and associated tags' do
      before :each do
        @user = User.new
        @user.email = "test@test.com"
        @user.save      
      end
      
      it 'should return user with no tags' do
        get "/api/v1/users/#{@user.id}", {}, @env
        expect(response.status).to eq(200)
        expect(JSON.parse(response.body)).to include("id" => @user.id, "email" => "test@test.com", "tags" => [])
      end
      
      it 'should return user with one tag' do
        @user.add_tags(["friendly"]) 
        get "/api/v1/users/#{@user.id}", {}, @env
        expect(response.status).to eq(200)
        expect(JSON.parse(response.body)).to include("id" => @user.id, "email" => "test@test.com", "tags" => ["friendly"])
      end
      
      it 'should return user with two tag' do
        @user.add_tags(["friendly","adventurous"])  
        get "/api/v1/users/#{@user.id}", {}, @env
        expect(response.status).to eq(200)
        expect(JSON.parse(response.body)).to include("id" => @user.id, "email" => "test@test.com")
        expect(JSON.parse(response.body)['tags']).to include("friendly","adventurous")
      end
      
      it 'should return 404 for user id not found' do
        get "/api/v1/users/345345", {}, @env
        expect(response.status).to eq(404)
        expect(JSON.parse(response.body)).to include("error" =>"User not found for id=345345")
      end
    end
    
    describe 'to search users associated to one or more tags' do
      before :each do
        @user = User.new
        @user.email = "test@test.com"
        @user.save     
        
        @user.add_tags(["friendly","adventurous"])   
      end
      
      it 'should return no users given empty tag list' do
        tags_param = { :tags => [] }
        post "/api/v1/users/search", tags_param.to_json, @env
        expect(response.status).to eq(201)
        expect(JSON.parse(response.body)).to eq([])
      end
      
      it 'should return one user that matches on two tags' do
        tags_param = { :tags => ["friendly","adventurous"] }
        post "/api/v1/users/search", tags_param.to_json, @env
        expect(response.status).to eq(201)
        expect(JSON.parse(response.body)[0]).to include("id" => @user.id, "email" => "test@test.com")
      end
      
      it 'should return one user that matched on one tag' do
        tags_param = { :tags => ["adventurous"] }
        post "/api/v1/users/search", tags_param.to_json, @env
        expect(response.status).to eq(201)
        expect(JSON.parse(response.body)[0]).to include("id" => @user.id, "email" => "test@test.com")
      end
      
      it 'should return two users that matched on one tag' do
        @user_two = User.new
        @user_two.email = "test2@test.com"
        @user_two.save
        @user_two.add_tags(["adventurous"])

        tags_param = { :tags => ["adventurous"] }
        post "/api/v1/users/search", tags_param.to_json, @env
        expect(response.status).to eq(201)
        expect(JSON.parse(response.body).length).to eq(2)
        # ordering is not guaranteed so check the order
        if JSON.parse(response.body)[0]['id'] == @user.id
          expect(JSON.parse(response.body)[0]).to include("id" => @user.id, "email" => "test@test.com")
          expect(JSON.parse(response.body)[1]).to include("id" => @user_two.id, "email" => "test2@test.com")
        else
          expect(JSON.parse(response.body)[1]).to include("id" => @user.id, "email" => "test@test.com")
          expect(JSON.parse(response.body)[0]).to include("id" => @user_two.id, "email" => "test2@test.com")
        end
      end
    end
  end
  
  describe 'unauthenticated requests' do
    describe 'to create user' do
      it 'should not create a user and return 401' do
        expect {
          post '/api/v1/users/', '{"email" : "test@test.com"}', @env
          expect(response.status).to eq(401)
          expect(response.body).to eq("")
        }.to change(User, :count).by(0)  
      end
    end
    
    describe 'regarding users and their tags' do
      before :each do
        @user = User.new
        @user.email = "test@test.com"
        @user.save      
      end
          
      it 'should return 401 for requests to add_tags' do
        tags_param = { :tags => ["friendly","adventurous"] }
        put "/api/v1/users/#{@user.id}/add_tags", tags_param.to_json, @env
        expect(response.status).to eq(401)
        expect(response.body).to eq("")
      end
      
      it 'should return 401 for requests to remove_tags' do
        tags_param = { :tags => ["friendly","adventurous"] }
        put "/api/v1/users/#{@user.id}/remove_tags", tags_param.to_json, @env
        expect(response.status).to eq(401)
        expect(response.body).to eq("")
      end
      
      it 'should return 401 for requests to get a user by id' do
        get "/api/v1/users/#{@user.id}", {}, @env
        expect(response.status).to eq(401)
        expect(response.body).to eq("")
      end
    end
    
    describe 'to search users' do
      it 'should return 401' do
        tags_param = { :users => ["friendly","adventurous"] }
        post "/api/v1/users/search", tags_param.to_json, @env
        expect(response.status).to eq(401)
        expect(response.body).to eq("")
      end
    end
  end
end
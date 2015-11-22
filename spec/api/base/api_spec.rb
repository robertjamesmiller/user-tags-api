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
    
    describe 'for create user' do
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
    
  end
 
  describe 'unauthenticated requests' do
    describe 'for create user' do
      it 'should not create a user and return 401' do
        expect {
          post '/api/v1/users/', '{"email" : "test@test.com"}', @env
          expect(response.status).to eq(401)
          expect(response.body).to eq("")
        }.to change(User, :count).by(0)  
      end
    end
  end
end
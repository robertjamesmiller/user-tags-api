require 'rails_helper'

RSpec.describe User, type: :model do
  
  describe "validation" do
    before :each do
      @user = User.new
    end
    
    it 'should fail with nil email' do
      expect(@user.valid?).to eq(false)
      expect(@user.errors[:email].size).to eq(1)
      expect(@user.errors[:email][0]).to eq("is not valid")
    end
    
    it 'should fail with empty email' do
      @user.email = ""
      
      expect(@user.valid?).to eq(false)
      expect(@user.errors[:email].size).to eq(1)
      expect(@user.errors[:email][0]).to eq("is not valid")
    end
  
    it 'should pass with valid email' do
      @user.email = "test@test.com"
      
      expect(@user.valid?).to eq(true)
    end
    
    it 'should fail with invalid email format' do
      @user.email = "testtest.com"
      
      expect(@user.valid?).to eq(false)
      expect(@user.errors[:email].size).to eq(1)
      expect(@user.errors[:email][0]).to eq("is not valid")
    end
    
    it 'should fail on create if duplicate email' do
      User.create(:email => "test@test.com")
      @user.email = "test@test.com"
      
      expect(@user.valid?).to eq(false)
      expect(@user.errors[:email].size).to eq(1)
      expect(@user.errors[:email][0]).to eq("has already been taken")
    end

  end
end

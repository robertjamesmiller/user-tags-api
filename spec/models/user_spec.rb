require 'rails_helper'

RSpec.describe User, type: :model do
  before :each do
    # clear redis before each test
    $redis.flushdb
  end
  
  describe "add_tags" do
    before :each do      
      @user = User.new
      @user.email = "test@test.com"
      @user.save
    end
         
    it 'should associate a tag to the user' do
      expect(@user.tags).to eq([])
      
      @user.add_tags(["funny"])
      expect(@user.tags).to eq(["funny"])    
    end
    
    it 'should associate two tags to the user' do
      expect(@user.tags).to eq([])
      
      @user.add_tags(["funny", "cyclist"])
      expect(@user.tags).to include("funny", "cyclist")    
    end
    
    it 'should not associate a duplicate tag to the user' do
      expect(@user.tags).to eq([])
      
      @user.add_tags(["funny", "funny"])
      expect(@user.tags).to eq(["funny"])    
    end
    
    it 'should not associate two duplicate tags to the user' do
      expect(@user.tags).to eq([])
      
      @user.add_tags(["funny", "cyclist","funny", "cyclist"])
      expect(@user.tags).to include("funny", "cyclist")       
    end
    
    it 'should do nothing if tag array is empty' do
      expect(@user.tags).to eq([])
      
      @user.add_tags([])
      expect(@user.tags).to eq([])    
    end
    
  end
  
  describe "remove_tags" do
    before :each do      
      @user = User.new
      @user.email = "test@test.com"
      @user.save
      
      @user.add_tags(["funny", "cyclist"])
    end
         
    it 'should disassociate a tag from the user' do      
      @user.remove_tags(["funny"])
      expect(@user.tags).to eq(["cyclist"])    
    end
   
    it 'should disassociate two tags from the user' do      
      @user.remove_tags(["cyclist","funny"])
      expect(@user.tags).to eq([])    
    end
    
    it 'should do nothing if tag array is empty' do      
      @user.remove_tags([])
      expect(@user.tags).to include("funny", "cyclist")
    end
    
    it 'should do nothing if tag array includes tags not currently associated' do      
      @user.remove_tags(["runner"])
      expect(@user.tags).to include("funny", "cyclist")
    end
    
    it 'should disassociate a tag from the user even one of the tags to be removed is not found' do      
      @user.remove_tags(["runner","funny"])
      expect(@user.tags).to eq(["cyclist"])    
    end
    
    it 'should disassociate a tag from the user even it is duplicated in the tag array' do      
      @user.remove_tags(["funny","funny"])
      expect(@user.tags).to eq(["cyclist"])    
    end
  end  
  
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

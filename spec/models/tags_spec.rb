require 'rails_helper'

RSpec.describe Tags, type: :model do
  before :each do
    # clear redis before each test
    $redis.flushdb
    
    @user_one = User.new
    @user_one.email = "test@test.com"
    @user_one.save
  end
  
  describe "add_user" do
    it 'should do nothing when tags array is empty' do        
      tags = Tags.new([])        
      tags.add_user(@user_one)
  
      expect(@user_one.tags).to eq([])   
    end
        
    it 'should associate a tag to the user' do        
      tags = Tags.new(["funny"])        
      tags.add_user(@user_one)
  
      expect(@user_one.tags).to eq(["funny"])   
    end
    
    it 'should associate two tags to the user' do        
      tags = Tags.new(["funny","cyclist"])        
      tags.add_user(@user_one)
  
      expect(@user_one.tags).to include("funny","cyclist")
    end
    
    it 'should not associate a duplicate tag to the user' do        
      tags = Tags.new(["funny","cyclist","funny"])        
      tags.add_user(@user_one)
  
      expect(@user_one.tags).to include("funny","cyclist")
    end
    
    it 'should not associate two duplicate tags to the user' do        
      tags = Tags.new(["funny","cyclist","funny","cyclist"])        
      tags.add_user(@user_one)
  
      expect(@user_one.tags).to include("funny","cyclist")
    end
  end
  
  describe "remove_user" do
    before :each do
      # add two tags to the user
      tags = Tags.new(["funny","cyclist"])   
      tags.add_user(@user_one) 
    end
    
    it 'should do nothing when tags array is empty' do        
      tags = Tags.new([])        
      tags.remove_user(@user_one)
  
      expect(@user_one.tags).to include("funny","cyclist") 
    end
    
    it 'should do nothing if tag to be removed is not associated with the user' do        
      tags = Tags.new(["runner"])        
      tags.remove_user(@user_one)
  
      expect(@user_one.tags).to include("funny","cyclist") 
    end
        
    it 'should disassociate a tag from the user' do    
      tags = Tags.new(["cyclist"])  
      tags.remove_user(@user_one)
  
      expect(@user_one.tags).to eq(["funny"])   
    end
    
    it 'should disassociate a tag from the user even if one of the tags is not associated to the user' do    
      tags = Tags.new(["cyclist","runner"])  
      tags.remove_user(@user_one)
  
      expect(@user_one.tags).to eq(["funny"])   
    end
    
    it 'should disassociate two tags from the user' do        
      tags = Tags.new(["funny","cyclist"])        
      tags.remove_user(@user_one)
  
      expect(@user_one.tags).to eq([])
    end
    
    it 'should disassociate two tags from the user even if one is duplicated in the tag array' do        
      tags = Tags.new(["funny","cyclist","funny"])        
      tags.remove_user(@user_one)
  
      expect(@user_one.tags).to eq([])
    end
    
    it 'should disassociate two tags from the user even if both are duplicated in the tag array' do                
      tags = Tags.new(["funny","cyclist","funny","cyclist"])        
      tags.remove_user(@user_one)
  
      expect(@user_one.tags).to eq([])
    end
  end
  
  describe "users" do
    it 'should return empty users array when tags array is empty' do        
      tags = Tags.new([])          
      expect(tags.users).to eq([])    
    end     
    
    describe "after adding users to tags" do
      it 'should return one user associated to the tag' do          
        tags = Tags.new(["funny"])        
        tags.add_user(@user_one)
    
        expect(tags.users).to eq(["#{@user_one.id}"])    
      end
      
      it 'should return one user associated to two tags, both individually and in combination' do          
        tags = Tags.new(["funny","cyclist"])        
        tags.add_user(@user_one)
    
        # the user is associated to both tags   
        expect(tags.users).to eq(["#{@user_one.id}"])  
        # funny tag has user
        funny_tag = Tags.new(["funny"])  
        expect(funny_tag.users).to eq(["#{@user_one.id}"])   
        # cyclist tag has user  
        cyclist_tag = Tags.new(["cyclist"])  
        expect(cyclist_tag.users).to eq(["#{@user_one.id}"])  
      end
      
      it 'should return two users associated to one of the tags, one user associated to the other tag' do          
        tags = Tags.new(["funny","cyclist"])        
        tags.add_user(@user_one)
        
        @user_two = User.new
        @user_two.email = "test@test.com"
        @user_two.save
        
        cyclist_tag = Tags.new(["cyclist"])    
        cyclist_tag.add_user(@user_two)  

        # user one is associated to both tags   
        expect(tags.users).to eq(["#{@user_one.id}"])  
        # cyclist tag has both users
        expect(cyclist_tag.users).to include("#{@user_one.id}","#{@user_two.id}")  
        # funny tag has user one
        funny_tag = Tags.new(["funny"])  
        expect(funny_tag.users).to eq(["#{@user_one.id}"])   
      end
    end
    
    describe "after removing a user from tags" do
      before :each do
        # add two tags to the user
        tags = Tags.new(["funny","cyclist"])   
        tags.add_user(@user_one)  
      end
      
      it 'should return zero users associated to one tag and the two tags in combination, but user is still associated to the other tag individually' do   
        funny_tag = Tags.new(["funny"])                  
        funny_tag.remove_user(@user_one)
        
        expect(funny_tag.users).to eq([]) 
          
        cyclist_tag = Tags.new(["cyclist"])  
        expect(cyclist_tag.users).to eq(["#{@user_one.id}"])  
        # user is longer matched to both tags in combination 
        tags = Tags.new(["funny","cyclist"]) 
        expect(tags.users).to eq([])  
      end
      
      it 'should return zero users associated to both tags, in combination and individually' do   
        tags = Tags.new(["funny","cyclist"]) 
        tags.remove_user(@user_one)
        
        expect(tags.users).to eq([]) 
        
        funny_tag = Tags.new(["funny"])
        expect(funny_tag.users).to eq([]) 
          
        cyclist_tag = Tags.new(["cyclist"])  
        expect(cyclist_tag.users).to eq([])  
      end
    end
  end
end

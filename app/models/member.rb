####################################################################################################################
#  This is the main Model file. This has all the  business logic
#  refer to Active Record Basics in https://guides.rubyonrails.org.
#  The constant file is in the lib directory. 
#  This model has one member_website. It has multiple friends, through multiple frienships
#  It has validations for it's attributes. It has couple of callback methods.
# 
#################################################################################################################### 

require "include_constants"
class Member < ApplicationRecord
  include IncludeConstants

  has_one :member_website
  has_many :friend_ships
  has_many :friends, :through => :friend_ships

  has_many :inverse_friend_ships, :class_name => "FriendShip", :foreign_key => "friend_id"
  has_many :inverse_friends, :through => :inverse_friend_ships, :source => :member

  before_save { self.email = email.downcase if email.present? }
  before_save :encode_password, if: :has_password?
  validates :first_name,
            #length: {minimum: MINIMUM_NAME_LENGTH, maximum: MAXIMUM_NAME_LENGTH},
            presence: true
  validates :last_name,
            #length: {minimum: MINIMUM_NAME_LENGTH, maximum: MAXIMUM_NAME_LENGTH},
            presence: true
  validates :url,
            length: {minimum: MINIMUM_URL_LENGTH, maximum: MAXIMUM_URL_LENGTH},
            presence: true
  validates :email,
            length: {minimum: MINIMUM_EMAIL_LENGTH, maximum: MAXIMUM_EMAIL_LENGTH},
            format: {with: EMAIL_REGEX, message: :bad_email_message},
            allow_blank: true, uniqueness: {case_sensitive: false},
            presence: true
  validates :auth_token, uniqueness: true, allow_blank: true         
  validates :password,
            length: {minimum: MINIMUM_PASSWORD_LENGTH, maximum: MAXIMUM_PASSWORD_LENGTH},
            #format: {with: PASSWORD_REGEX, message: :bad_password_message},
            confirmation: true,
            presence: true, allow_blank: true
  ###################################################################################################################################

  def has_password?
    password != nil ? true :false
  end

  #This method is called two times, when the member gets created/sign_up and when the member login happens.
  def encrypt_password(password, salt)
    secure_hash("#{password}--#{salt}")
  end

  #This is called, when the member is created with create API call
  #This stores the headings, the website is created and short_url 
  #created and stored. Please check create_shorturl for more info.
  #all the heading (h1-h3) values are pulled in from the website to that members profile.
  def self.create_member(member_details)
    member = nil
    member = Member.new(member_details)
    if member.save!
      headings = read_webpage_headings(member_details[:url])
      website = member.member_website=MemberWebsite.new(website_url:member_details[:url], 
      short_url: create_shorturl(member_details[:url]), heading_h1: headings[:h1], 
      heading_h2: headings[:h2], heading_h3: headings[:h3]) 
    end
    member
  end

  #Token and the Client for this are available in config/initializers/myapp.rb file
  #It is called in Create_member
  def self.create_shorturl(url)
    bitlink = BITLEY_CLIENT.shorten(long_url: url)
    bitlink.link
  end

  #This is called by create_member
  def self.read_webpage_headings(url)
    h1 = h2 = h3 = nil
    response = Nokogiri::HTML(HTTParty.get(url))
    if response.css("h1").present?
      h1 = response.css("h1").map { |e| e.text } 
      h1 = h1.join(",")
    end

    if response.css("h2").present?
      h2 = response.css("h2").map { |e| e.text } 
      h2 = h2.join(",")
    end

    if response.css("h3").present?
      h3 = response.css("h3").map { |e| e.text } 
      h3 = h3.join(",")
    end
    {
      h1: h1, 
      h2: h2, 
      h3: h3
    }
  end

  #This method gets experts from the member's friends_friend_list
  #Now, looking at Alan's profile, It is possible to find experts in the 
  #application who write about a certain topic and are not already friends of Alan.
  #Results show the path of introduction from Alan to the expert e.g. Alan 
  # wants to get introduced to someone who writes about 'Dog breeding'. 
  #Claudia's website has a heading tag "Dog breeding in Ukraine". Bart knows Alan and Claudia. 
  #An example search result would be Alan -> Bart -> Claudia ("Dog breeding in Ukraine").

  def get_experts

    member_website = self.member_website
    raise Exception.new("Member id:#{self.id}, do not have a valid website URL") if member_website.blank?
    friends = self.friends.select(:id, :first_name, :email)
    friends_friend_headings = [] 
    
    friends.each do |friend|

      #member'sfriends_friends excluding the member
      friends_friends=friend.friends.select(:id, :first_name, :email).where.not(id: self.id)
      friends_ids = friends_friends.map(&:id)
      
      #This loop will get  all headings, h1,h2 and h3 into friends_friend_headings
      # calling friends_sriend_heading_tags

      friends_friends.each do |friends_friend|
        friends_friend_headings << {
          link_id: "#{self.id}->#{friend.id}->#{friends_friend.id}",
          link_name: "#{self.first_name}->#{friend.first_name}->#{friends_friend.first_name}"        
        }.merge(friends_friend_heading_tags(friends_friend.id))
      end

    end
      
    rec_friends = []
    
    friends_friend_headings.each do|heading_keywords|
      # Keeps a score for every matching heading 
      score = 0
      heading_h1_tags = heading_h2_tags = heading_h3_tags = []
      matched_headings = []
      
      heading_h1_tags = member_website.heading_h1 if member_website.heading_h1.present?
      matching_heading_h1 = heading_keywords[:friends_friend_heading_tags].intersection([heading_h1_tags])
      
      
      if(matching_heading_h1.present?)
        score = score + 10 * matching_heading_h1.size
        matched_headings << matching_heading_h1
        heading_keywords[:link_name] = heading_keywords[:link_name] << "(#{matching_heading_h1.to_s.gsub(/"/,"").to_s.sub("[", "'").sub("]","'")})"
      end

      heading_h2_tags = member_website.heading_h2 if member_website.heading_h2.present?
      matching_heading_h2 = heading_keywords[:friends_friend_heading_tags].intersection([heading_h2_tags])

      if(matching_heading_h2.present?)
        score = score + 10 * matching_heading_h2.size
        matched_headings << matching_heading_h2
        heading_keywords[:link_name] = heading_keywords[:link_name] << "(#{matching_heading_h2.to_s.gsub(/"/,"").to_s.sub("[", "'").sub("]","'")})"
      end


      heading_h3_tags = member_website.heading_h3 if member_website.heading_h3.present?
      matching_heading_h3 = heading_keywords[:friends_friend_heading_tags].intersection([heading_h3_tags])

      if(matching_heading_h3.present?)
        score = score + 10 * matching_heading_h3.size
        matched_headings << matching_heading_h3
        heading_keywords[:link_name] = heading_keywords[:link_name] << "(#{matching_heading_h3.to_s.gsub(/"/,"").to_s.sub("[", "'").sub("]","'")})"
      end
      if(score>0)
        heading_keywords[:score] = score
    
        rec_friends << {
          friends_friend_id: heading_keywords[:friends_friend_id],
          link_id: heading_keywords[:link_id],
          link_name: heading_keywords[:link_name],
          score: heading_keywords[:score],
          matched_headings: matched_headings
        }
      end

    end
    rec_friends # Returning the recommendations
  end

  # This method returns all headings of the friends_friend.
  # This method is called by get_experts
  def friends_friend_heading_tags(friends_friend_id)
    
    member_id = friends_friend_id
    website = MemberWebsite.select(:member_id, :heading_h1, :heading_h2,
    :heading_h3).where(member_id: member_id).first
    keytags = []
    heading_keytags = {member_id: member_id, friends_friend_keywords: []}
    if(website.present?)
      keytags << website.heading_h1 if website.heading_h1.present?
      keytags << website.heading_h2 if website.heading_h2.present?
      keytags << website.heading_h3 if website.heading_h3.present?
      uniq_keytags = keytags.flatten.uniq
      heading_keytags = {friends_friend_id: website.member_id, friends_friend_heading_tags: uniq_keytags}
    end
    heading_keytags
  end

  # This is called by index API. 
  # list all members with their name, short url and the number of friends
  def self.member_details
    members = Member.includes(:friends).all
    result = []
    members.each do |member|
      result << {
        #id: member.id,
        name: "#{member.first_name} #{member.last_name}",
        short_url: member.member_website.short_url,
        no_of_friends: member.friends.size
      }
    end
    result
  end

  #an actual member should display the name, website URL, shortening, website headings, and 
  #links to their friends' pages
  #The following 3 methods,member_info, website_info and friend_with_links are used for that
  def member_info
    result = []
    result << {
      name: "#{self.first_name} #{self.last_name}",
      website_url: "#{self.url}",
      short_url: "#{self.member_website.short_url}"
    }
    result
  end

  def website_info
    result = []
    result << {
      headin_h1: "#{self.member_website.heading_h1}",
      headin_h2: "#{self.member_website.heading_h2}",
      headin_h3: "#{self.member_website.heading_h3}"
    }

    result
  end

  def friend_with_links
    friends = self.friends
    result = []
    friends.each do |friend|
      result  << {
        #id: friend.id,
        name: "#{friend.first_name} #{friend.last_name}",
        friend_link: "http://localhost:3000/api/v1/members/#{friend.id}" 
      }
    end
    result
  end

  # This is called by login API call. It checks if the password is correct
  # Then it will enable the session
  def self.authenticate(email, password)
    email = email.downcase
    member = Member.where(email: email).first
    if member.present? && member.password == member.encrypt_password(password, member.salt)
      member.enable_session
      member
    else
      nil
    end
  end

  # This enables the session and generates the auth token
  # There are couple of API calls which require auth_token to execute.
  def enable_session
    self.auth_token = secure_hash("#{Time.now.to_s} -- #{Random.rand(10000000).to_s}")
    self.is_token_valid = true
    self.save!
  end

  # This method adds a friend to a member. There are two arguments
  # Here the member gets a friend also in reverse the friend also
  # gets the member as his friend
  def self.add_friend(member_id,friend_id)
    member = Member.where(id: member_id).first
    unless(FriendShip.exists?(member_id: member_id, friend_id: friend_id))
      #member = Member.find(params[:member_id])
      member.friends << Member.find(friend_id)
      friend=Member.where(id: friend_id).first
      friend.friends << member
      msg = "Friend added successfully"
    else
      msg = "Friend already added"
    end
    {member: member, msg: msg}
  end

  
private 

  # All methods here are connected with security
  # the functionality is self explanatory
  def make_salt(password)
    secure_hash("#{Time.now.utc}--#{password}")
  end

  def secure_hash(string)
    Digest::SHA2.hexdigest(string)
  end

  def encode_password
    if self.password_changed?
      salt = make_salt(password)
      self.salt = salt
      #self.password = password
      self.password = encrypt_password(password, salt)
    end
  end

end

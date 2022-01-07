require "include_constants"
class Member < ApplicationRecord
  include IncludeConstants

  has_one :member_website
	
  has_many :friend_ships
  has_many :friends, :through => :friend_ships

  has_many :inverse_friend_ships, :class_name => "FriendShip", :foreign_key => "friend_id"
  has_many :inverse_friends, :through => :inverse_friend_ships, :source => :member

  before_save { self.email = email.downcase if email.present? }
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
            #allow_blank: true, uniqueness: {message: :email_conflict_message, case_sensitive: false},
            presence: true
  validates :password,
            length: {minimum: MINIMUM_PASSWORD_LENGTH, maximum: MAXIMUM_PASSWORD_LENGTH},
            #format: {with: PASSWORD_REGEX, message: :bad_password_message},
            confirmation: true,
            presence: true, allow_blank: true

  def self.create_member(member_details)
    member = nil
    member_details[:password] = Base64.decode64(member_details[:password])
    member = Member.new(member_details)
    if member.save!
      headings = read_webpage_headings(member_details[:url])
      website = member.member_website=MemberWebsite.new(website_url:member_details[:url], 
      short_url: create_shorturl(member_details[:url]), heading_h1: headings[:h1], 
      heading_h2: headings[:h2], heading_h3: headings[:h3]) 
    end
    member
  end

  def self.create_shorturl(url)
    bitlink = BITLEY_CLIENT.shorten(long_url: url)
    bitlink.link
  end

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

  def get_experts
    member_website = self.member_website
    raise Exception.new("Member id:#{self.id}, do not have a valid website URL") if member_website.blank?
    friends = self.friends.select(:id, :first_name, :email)
    member_headings = [] 
    friends.each do |friend|
  
        friends_friends=friend.friends.select(:id, :first_name, :email).where.not(id: self.id)
        friends_ids = friends_friends.map(&:id)
        #member_headings = MemberWebsite.heading_keywords(friend, friends_ids) 
        
        friends_friends.each do |friends_friend|
          member_headings << {
            link_id: "#{self.id}->#{friend.id}->#{friends_friend.id}",
            link_name: "#{self.first_name}->#{friend.first_name}->#{friends_friend.first_name}"        
          }.merge(member_heading_keywords(friends_friend.id))
         end
        
      end
      
      
      rec_friends = []
      
      member_headings.each do|heading_keywords|
        score = 0
        heading_h1_words = heading_h2_words = heading_h3_words = []
        matched_keywords = []
        heading_h1_words = member_website.heading_h1.gsub(",", " ").squeeze.split(" ") if member_website.heading_h1.present?
        matching_words_h1 = heading_keywords[:matched_friends_friend_heading_keywords].intersection(heading_h1_words)
        if(matching_words_h1.present?)
          score = score + 10 * matching_words_h1.size
          matched_keywords << matching_words_h1
          #matched_keywords << member_website.heading_h1
        end

        heading_h2_words = member_website.heading_h2.gsub(",", " ").squeeze.split(" ") if member_website.heading_h2.present?
        matching_words_h2 = heading_keywords[:matched_friends_friend_heading_keywords].intersection(heading_h2_words)
        if(matching_words_h2.present?)
          score = score + 10 * matching_words_h2.size
          matched_keywords << matching_words_h2
          #matched_keywords << member_website.heading_h2
        end

        heading_h3_words = member_website.heading_h3.gsub(",", " ").squeeze.split(" ") if member_website.heading_h3.present?
        matching_words_h3 = heading_keywords[:matched_friends_friend_heading_keywords].intersection(heading_h3_words)
        if(matching_words_h3.present?)
          score = score + 10 * matching_words_h3.size
          matched_keywords << matching_words_h3
          #matched_keywords << member_website.heading_h3
        end

        if(score>0)
          heading_keywords[:score] = score
          heading_keywords[:member_heading_keywords] = matched_keywords.flatten.uniq
          #rec_friends << heading_keywords
          rec_friends.unshift(heading_keywords)
        end

      end
      rec_friends
  end

  def member_heading_keywords(member_id)
    #debugger
    website = MemberWebsite.select(:member_id, :heading_h1, :heading_h2,
     :heading_h3).where(member_id: member_id).first
    keywords = []
   heading_keywords = {member_id: member_id, friends_friend_keywords: []}
    if(website.present?)
      keywords << website.heading_h1.gsub(",", " ").squeeze.split(" ") if website.heading_h1.present?
      keywords << website.heading_h2.gsub(",", " ").squeeze.split(" ") if website.heading_h2.present?
      keywords << website.heading_h3.gsub(",", " ").squeeze.split(" ") if website.heading_h3.present?
      uniq_keywords = keywords.flatten.uniq
      heading_keywords = {friends_friend_id: website.member_id, matched_friends_friend_heading_keywords: uniq_keywords}
    end
    heading_keywords
  end


  def heading_keywords(member_ids)
    #debugger
    websites = MemberWebsite.select(:member_id, :heading_h1, :heading_h2, :heading_h3).where(member_id: member_ids)
    keywords = []
    member_headings = []
    websites.each do |website|
      keywords << website.heading_h1.gsub(",", " ").squeeze.split(" ") if website.heading_h1.present?
      keywords << website.heading_h2.gsub(",", " ").squeeze.split(" ") if website.heading_h2.present?
      keywords << website.heading_h3.gsub(",", " ").squeeze.split(" ") if website.heading_h3.present?
      uniq_keywords = keywords.flatten.uniq
      member_headings << {member_id: website.member_id, keywords: uniq_keywords}
    end
    member_headings
  end

  def self.member_details
    members = Member.includes(:friends).all
    result = []
    members.each do |member|
      result << {
        id: member.id,
        name: "#{member.first_name} #{member.last_name}",
        short_url: member.member_website.short_url,
        no_of_friends: member.friends.size

      }
    end
    result
  end

  def friend_with_links
    friends = self.friends
    result = []
    friends.each do |friend|
      result  << {
      id: friend.id,
      name: "#{friend.first_name} #{friend.last_name}",
      friend_link: "http://localhost:3000/api/v1/members/#{friend.id}" 
      }
    end
    result
  end

# <a href="http://localhost:3000/api/v1/members/5"+friend_id />

  def self.add_friend(member_id, friend_id)
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
    {member: member, msg: msg }
  end

end

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

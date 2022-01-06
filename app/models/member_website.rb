class MemberWebsite < ApplicationRecord
  belongs_to :member

  def self.heading_keywords(friend, member_ids)
    #debugger
    websites = MemberWebsite.select(:member_id, :heading_h1, :heading_h2, :heading_h3).where(member_id: member_ids)
    keywords = []
    member_headings = []
    websites.each do |website|
      keywords << website.heading_h1.gsub(",", " ").squeeze.split(" ") if website.heading_h1.present?
      keywords << website.heading_h2.gsub(",", " ").squeeze.split(" ") if website.heading_h2.present?
      keywords << website.heading_h3.gsub(",", " ").squeeze.split(" ") if website.heading_h3.present?
      uniq_keywords = keywords.flatten.uniq
      member_headings << {
        member_id: website.member_id,
        keywords: uniq_keywords,
        link_id: "#{friend.id}_#{friends_friend.id}",
        link_name: "#{friend.first_name}_#{friends_friend.first_name}",
      }
    end
    member_headings
  end
end

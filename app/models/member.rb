require "include_constants"
class Member < ApplicationRecord
	include IncludeConstants

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
end

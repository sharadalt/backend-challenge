module IncludeConstants

  NAME_REGEX = /\A[^[:cntrl:]\\<>\/&]*\z/ # Unicode, permissive
  BAD_NAME_MESSAGE = "avoid non-printing characters and \\&gt;&lt;&amp;/ please."
  MINIMUM_PASSWORD_LENGTH = 8
  MAXIMUM_PASSWORD_LENGTH = 30

  EMAIL_NAME_REGEX = '[\w\.%\+\-]+'.freeze
  DOMAIN_HEAD_REGEX = '(?:[A-Z0-9](?:[A-Z0-9-]*[A-Z0-9])?\.)+'.freeze
  DOMAIN_TLD_REGEX = '(?:[A-Z]{2,})'.freeze
  EMAIL_REGEX = /\A#{EMAIL_NAME_REGEX}@#{DOMAIN_HEAD_REGEX}#{DOMAIN_TLD_REGEX}\z/i
    
  PASSWORD_REGEX = /\A(?=.*[0-9])(?=.*[a-zA-Z])(?=.*[ \.\~\`\!\@\#\$\%\^\&\*\(\)\_\+\-\=\{\[\}\]\\\|\:\;\"\'\<\>\,\?\/]).{#{MINIMUM_PASSWORD_LENGTH},#{MAXIMUM_PASSWORD_LENGTH}}\z/
  BAD_PASSWORD_MESSAGE = "must contain #{MINIMUM_PASSWORD_LENGTH} to #{MAXIMUM_PASSWORD_LENGTH} characters, with at least one letter, one numerical digit, and one special character"

  MINIMUM_EMAIL_LENGTH = 8
  MAXIMUM_EMAIL_LENGTH = 255

  MINIMUM_NAME_LENGTH = 8
  MAXIMUM_NAME_LENGTH = 255

  MINIMUM_URL_LENGTH = 8
  MAXIMUM_URL_LENGTH = 255
end
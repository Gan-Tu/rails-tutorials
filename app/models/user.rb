class User < ApplicationRecord
    before_save { email.downcase! }

    # equivalent: validates(:name, presence: true)
    validates :name,    presence: true, 
                        length: { maximum: 50}
    
    VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i
    validates :email,   presence: true, 
                        length: { maximum: 255},
                        format: { with: VALID_EMAIL_REGEX },
                        # if we use "uniqueness: true"
                        # it will be case sensitive, while it shouldn't be for email
                        uniqueness: { case_sensitive: false }
end
    
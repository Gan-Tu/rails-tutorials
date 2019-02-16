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
    
    # for more: https://goo.gl/wLvfto
    # - automatically add 'password_confirmation', 'authenticate' method
    # - Adds methods to set and authenticate against a BCrypt password. T
    # his mechanism requires you to have a password_digest attribute.
    has_secure_password 

    validates :password, presence: true, # ensures non-empty
                         length: { minimum: 6 }

    # Return the hash digest of the given string
    def User.digest(string)
        cost = ActiveModel::SecurePassword.min_cost ? 
                    BCrypt::Engine::MIN_COST : BCrypt::Engine::cost
        return BCrypt::Password.create(string, cost: cost)
    end
end
    
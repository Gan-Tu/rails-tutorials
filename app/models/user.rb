class User < ApplicationRecord
    attr_accessor :remember_token

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

    # Returns a random token
    def User.new_token
        SecureRandom.urlsafe_base64
    end

    # Remembers a user in the database for use in persistent sessions
    def remember
        self.remember_token = User.new_token
        update_attribute(:remember_digest, User.digest(remember_token))
    end

    # Returns true if the given token matches the remember_digest
    # Returns false if user digest is nil (meaning no persistent login enabled)
    def authenticated?(remember_token)
        # built-in for checking remember_digest == digest(remember_token)
        return !remember_digest.nil? && 
                BCrypt::Password.new(self.remember_digest)
                                .is_password?(remember_token)
    end

    # Forgets a user
    def forget
        self.remember_token = nil
        update_attribute(:remember_digest, nil)
    end
end
    
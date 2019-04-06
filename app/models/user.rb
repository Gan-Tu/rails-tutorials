class User < ApplicationRecord

    attr_accessor :remember_token, :activation_token, :reset_token
    before_save   :downcase_email
    before_create :create_activation_digest

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
    # his mechanism requires you to have a password_digest attribute
    # - Validations for presence of password on create, confirmation of 
    # password (using a password_confirmation attribute) are 
    # automatically added. 
    has_secure_password 

    validates :password, presence: true, # ensures non-empty
                         length: { minimum: 6 },
                         allow_nil: true

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

    # # Returns true if the given token matches the remember_digest
    # # Returns false if user digest is nil (meaning no persistent login enabled)
    # def authenticated?(remember_token)
    #     # built-in for checking remember_digest == digest(remember_token)
    #     return !remember_digest.nil? && 
    #             BCrypt::Password.new(self.remember_digest)
    #                             .is_password?(remember_token)
    # end

    # Returns true if the given token matches the digest.
    # This uses Ruby's MetaProgramming, where we can call a method using
    # 'send' and dynamically access its methods/functions/attributes
    # Here, we enable access xxxx_digest dynamically
    def authenticated?(attribute, token)
        digest = send("#{attribute}_digest")
        return false if digest.nil?
        BCrypt::Password.new(digest).is_password?(token)
    end

    # Forgets a user
    def forget
        self.remember_token = nil
        update_attribute(:remember_digest, nil)
    end

    # Activate an acccount
    def activate
        update_columns(activated: true,
                       activated_at: Time.zone.now)
    end

    # Sends activation email.
    def send_activation_email
        UserMailer.account_activation(self).deliver_now
    end

    # Sets the password reset attributes.
    def create_reset_digest
        self.reset_token = User.new_token
        update_attribute(:reset_digest,  User.digest(reset_token))
        update_attribute(:reset_sent_at, Time.zone.now)
    end

    # Sends password reset email.
    def send_password_reset_email
        UserMailer.password_reset(self).deliver_now
    end

    private

        # Converts email to all lower-case.
        def downcase_email
            self.email.downcase!
        end

        # Creates and assigns the activation token and digest.
        def create_activation_digest
            self.activation_token  = User.new_token
            self.activation_digest = User.digest(activation_token)
        end
end
    
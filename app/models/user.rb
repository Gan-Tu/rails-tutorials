class User < ApplicationRecord

    ##########################################################
    #                  DATABASE RELATIONSHIPS                #
    ##########################################################

    # a user has many microposts
    has_many :microposts, dependent: :destroy

    # a user can follow other users
    has_many :active_relationships, class_name:  "Relationship",
                                    foreign_key: "follower_id",
                                    dependent:   :destroy
    has_many :following, through: :active_relationships,
                         source: :followed

    # a user is followed by other users
    has_many :passive_relationships, class_name:  "Relationship",
                                     foreign_key: "followed_id",
                                     dependent:   :destroy
    has_many :followers, through: :passive_relationships,
                         source: :follower

    ##########################################################
    #                       ATTRIBUTES                       #
    ##########################################################

    # attributes
    attr_accessor :remember_token, :activation_token, :reset_token

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

    validates :password, presence: true, # ensures non-empty
                         length: { minimum: 6 },
                         allow_nil: true

    ##########################################################
    #                     AUTHENTICATION                     #
    ##########################################################

    # actions
    before_save   :downcase_email
    before_create :create_activation_digest

    # for more: https://goo.gl/wLvfto
    # - automatically add 'password_confirmation', 'authenticate' method
    # - Adds methods to set and authenticate against a BCrypt password. T
    # his mechanism requires you to have a password_digest attribute
    # - Validations for presence of password on create, confirmation of
    # password (using a password_confirmation attribute) are
    # automatically added.
    has_secure_password

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

    ##########################################################
    #                 ACTIVATION  & RESET                    #
    ##########################################################

    # Activate an account
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
        # update_attribute(:reset_digest,  User.digest(reset_token))
        # update_attribute(:reset_sent_at, Time.zone.now)
        update_columns(reset_digest:  User.digest(reset_token),
                       reset_sent_at: Time.zone.now)
    end

    # Sends password reset email.
    def send_password_reset_email
        UserMailer.password_reset(self).deliver_now
    end

    # Returns true if a password reset has expired.
    def password_reset_expired?
        self.reset_sent_at < 2.hours.ago
    end

    ##########################################################
    #                          FEEDING                       #
    ##########################################################

    # Defines a proto-feed.
    def feed
        # Rails interpret 'following_ids' from 'following'
        following_ids = "SELECT followed_id FROM relationships
                         WHERE  follower_id = :user_id"
        Micropost.where("user_id IN (#{following_ids})
                         OR user_id = :user_id", user_id: id)
    end

    # Follows a user.
    def follow(other_user)
        following << other_user
    end

    # Unfollows a user.
    def unfollow(other_user)
        following.delete(other_user)
    end

    # Returns true if the current user is following the other user.
    def following?(other_user)
        following.include?(other_user)
    end

    # Returns true if the current user has the other user as a follower
    def followed_by?(other_user)
        followers.include?(other_user)
    end


    ##########################################################
    #                    PRIVATE UTILITIES                   #
    ##########################################################

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

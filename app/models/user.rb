class User < ApplicationRecord
    # equivalent: validates(:name, presence: true)
    validates :name, presence: true
    validates :email, presence: true
end
    
class User < ActiveRecord::Base
    has_many :deposits
    has_many :withdrawals
    has_secure_password
end
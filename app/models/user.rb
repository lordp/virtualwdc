class User < ActiveRecord::Base
  has_secure_password
  attr_accessor :regenerate_token

  validates :email, :uniqueness => true, :presence => true
  validates :token, :uniqueness => true, :allow_blank => true

  has_many :drivers

  has_many :sessions, :through => :drivers

  before_save :generate_token, :if => lambda { |u| u.regenerate_token == "1" || u.new_record? || u.token.blank? }

  def has_claimed?(driver)
    self.drivers.include?(driver)
  end

  def generate_token(update = true)
    e = self.email.split(//)
    p = self.password_digest.split(//).shuffle.slice(0, e.size - 1)
    k = SecureRandom.urlsafe_base64(15).tr('lIO0', 'sxyz')
    t = OpenSSL::HMAC.hexdigest('SHA256', k, e.zip(p).flatten.join(''))
    if update
      self.token = t
    else
      t
    end
  end
end

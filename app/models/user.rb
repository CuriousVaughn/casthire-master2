class User < ActiveRecord::Base
  has_many :castings

  enum kind: { user: 0, admin: 1 }

  has_secure_password

  validates :password, :length => { :minimum => 6 },
            :on => :create

  validates :password, :length => { :minimum => 6 },
            :on => :update,
            :if => :password_digest_changed?

  validates_uniqueness_of :email, :case_sensitive => false, :message => 'is in use.'
  validates_presence_of   :email

  before_create { generate_token(:auth_token) }
  before_create { generate_token(:confirmation_token) }

  def confirm
    self.touch(:confirmed_at)
  end

  def confirmed?
    !!self.confirmed_at
  end

  def generate_token(column)
    self[column] = unique_token_for(column)
  end

  def unique_token_for(column)
    begin
      token = SecureRandom.urlsafe_base64
    end while User.exists?(column => token)
    token
  end

  def send_password_reset_email
    generate_token(:password_reset_token)
    self.password_reset_sent_at = Time.zone.now
    self.save!
    UserMailer.password_reset(self.id).deliver
  end

  def send_confirmation_email
    UserMailer.email_confirmation(self.id).deliver
  end
end

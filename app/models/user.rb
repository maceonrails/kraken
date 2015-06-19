# == Schema Information
#
# Table name: users
#
#  id                     :uuid             not null, primary key
#  email                  :string           default(""), not null
#  encrypted_password     :string           default(""), not null
#  username               :string           default(""), not null
#  token                  :string           default(""), not null
#  role                   :integer          default(5)
#  reset_password_token   :string
#  reset_password_sent_at :datetime
#  remember_created_at    :datetime
#  sign_in_count          :integer          default(0), not null
#  current_sign_in_at     :datetime
#  last_sign_in_at        :datetime
#  current_sign_in_ip     :inet
#  last_sign_in_ip        :inet
#  created_at             :datetime
#  updated_at             :datetime
#

class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  has_one :profile
  before_save  :ensure_authentication_token
  after_create :create_profile
  enum role:               
    [ 
      :eresto, :superadmin, :manager, :assistant_manager, 
      :waitress, :captain, :cashier, :chef
    ]

  ## Remove email field
  def email_required?
    false
  end

  def email_changed?
    false
  end

  def ensure_authentication_token
    if token.blank?
      self.token = generate_authentication_token
    end
  end

  def create_profile
    build_profile({})
  end
 
  private
    def generate_authentication_token
      loop do
        token = Devise.friendly_token
        break token unless User.where(token: token).first
      end
    end
end

class ApiClient < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable,
  # :lockable, :timeoutable and :omniauthable
  # :database_authenticatable, :registerable,
  # :recoverable, :rememberable, :trackable, :validatable
  devise :token_authenticatable

  attr_accessible :name

  before_save :ensure_authentication_token
  validates_presence_of :name
end

require "gds-sso/user"

class User
  include Mongoid::Document
  include Mongoid::Timestamps
  include GDS::SSO::User

  field "name",    type: String
  field "uid",     type: String
  field "version", type: Integer
  field "email",   type: String
  field "permissions", type: Hash

  attr_accessible :email, :name, :uid, :version

  def self.find_by_uid(uid)
    where(uid: uid).first
  end

  def to_s
    name || email || ""
  end
end
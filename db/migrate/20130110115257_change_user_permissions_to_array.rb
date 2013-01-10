class ChangeUserPermissionsToArray < Mongoid::Migration
  class User
    include Mongoid::Document
    include Mongoid::Timestamps

    field "permissions"

    # Migrations should be independent of the app, so we need this class, but 
    # it was defaulting the collection_name to the migration's class name.
    def self.collection_name
      "users"
    end
  end

  def self.up
    User.all.each do |user|
      if user.permissions.is_a?(Hash)
        user.permissions = user.permissions["Migratorator"]
        user.save!
      end
    end
  end

  def self.down
    User.all.each do |user|
      unless user.permissions.nil?
        user.permissions = { "Migratorator" => user.permissions }
        user.save!
      end
    end
  end
end
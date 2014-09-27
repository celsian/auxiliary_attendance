class AddTeacherAndAdminToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :teacher, :boolean, :default => false
    add_column :users, :admin, :boolean, :default => false
  end

  def self.down
    remove_column :users, :teacher
    remove_column :users, :admin
  end
end

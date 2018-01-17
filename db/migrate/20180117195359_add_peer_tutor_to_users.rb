class AddPeerTutorToUsers < ActiveRecord::Migration
  def change
    add_column :users, :peer_tutor, :boolean, :default => false
  end
end

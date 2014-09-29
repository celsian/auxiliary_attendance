class CreateClassSessions < ActiveRecord::Migration
  def change
    create_table :class_sessions do |t|
      t.string :name
      t.references :user, index: true
      t.boolean :closed, :default => false
      t.string :participants
      t.datetime :end_time

      t.timestamps
    end
  end
end

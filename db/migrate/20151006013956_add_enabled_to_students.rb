class AddEnabledToStudents < ActiveRecord::Migration
  def change
    add_column :students, :enabled, :boolean, default: true
  end
end
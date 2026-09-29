class AddProfileToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :profile, :string
  end
end

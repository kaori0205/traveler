class RenameMeesageToMessages < ActiveRecord::Migration[5.2] # バージョン番号は環境に合わせてください
  def change
    rename_column :messages, :meesage, :message
  end
end
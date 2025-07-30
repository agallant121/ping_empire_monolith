class AddUserToWebsites < ActiveRecord::Migration[8.0]
  def change
    add_reference :websites, :user, null: false, foreign_key: true
  end
end

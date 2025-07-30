class AddUserToWebsites < ActiveRecord::Migration[7.0]
  def change
    add_reference :websites, :user, foreign_key: true
  end
end

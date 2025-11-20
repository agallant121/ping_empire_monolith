class CreateAwsArchiveSettings < ActiveRecord::Migration[8.0]
  def change
    create_table :aws_archive_settings do |t|
      t.string :access_key_id, null: false
      t.string :secret_access_key, null: false
      t.string :session_token
      t.string :region, null: false
      t.string :bucket, null: false
      t.string :key_prefix

      t.timestamps
    end
  end
end

class RemoveCheckedAtFromResponses < ActiveRecord::Migration[8.0]
  def change
    remove_column :responses, :checked_at, :datetime
  end
end

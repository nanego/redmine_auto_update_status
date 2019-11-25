class AddTrackersToAutoUpdateRules < ActiveRecord::Migration[5.2]
  def change
    add_column :auto_update_rules, :tracker_ids, :string
  end
end

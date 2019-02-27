class CreateAutoUpdateRules < ActiveRecord::Migration[5.2]
  def change
    create_table :auto_update_rules do |t|
      t.string :initial_status_ids
      t.integer :final_status_id
      t.integer :time_limit
      t.text :note
      t.integer :author_id
    end
  end
end

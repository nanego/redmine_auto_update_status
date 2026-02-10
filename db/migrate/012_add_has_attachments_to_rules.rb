# frozen_string_literal: true

class AddHasAttachmentsToRules < ActiveRecord::Migration[7.2]
  def change
    add_column :auto_update_rules, :has_attachments, :string, default: ""
  end
end

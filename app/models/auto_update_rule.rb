class AutoUpdateRule < ActiveRecord::Base

  include Redmine::SafeAttributes

  serialize :initial_status_ids

  safe_attributes "initial_status_ids", "final_status_id", "time_limit", "note", "author_id"



end

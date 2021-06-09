class AutoUpdateRuleProject < ActiveRecord::Base

  belongs_to :project
  belongs_to :auto_update_rule

end

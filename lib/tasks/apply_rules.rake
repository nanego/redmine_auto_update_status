namespace :redmine do
  namespace :auto_update_status do

    desc "Apply all active rules"
    task apply_rules: :environment do

      AutoUpdateRule.active.find_each do |rule|

        puts "* Applying rule #{rule.id} - #{rule.name}"

        rule.apply_to_all_issues

      end

    end

  end
end

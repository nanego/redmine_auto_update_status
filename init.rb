require 'redmine_auto_update_status/hooks'

ActiveSupport::Reloader.to_prepare do
  require_dependency 'redmine_auto_update_status/issue_patch'
end

Redmine::Plugin.register :redmine_auto_update_status do
  name 'Redmine Auto Update Status plugin'
  author 'Vincent ROBERT'
  description 'This is a plugin for Redmine which helps to automatically update issues statuses'
  version '1.0.0'
  url 'https://github.com/nanego/redmine_auto_update_status'
  author_url 'https://github.com/nanego/redmine_auto_update_status'
  menu :admin_menu, :auto_update_rules, { :controller => 'auto_update_rules', :action => 'index' },
       :caption => :label_auto_update_rules,
       :html => {:class => 'icon'}
end

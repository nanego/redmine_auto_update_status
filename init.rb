# frozen_string_literal: true

require 'redmine'
require_relative 'lib/redmine_auto_update_status/hooks'

Redmine::Plugin.register :redmine_auto_update_status do
  name 'Redmine Auto Update Status plugin'
  author 'Vincent ROBERT'
  description 'This is a plugin for Redmine which helps to automatically update issues statuses'
  version '1.0.0'
  url 'https://github.com/nanego/redmine_auto_update_status'
  author_url 'https://github.com/nanego/redmine_auto_update_status'
end

# Ensure routes are loaded before adding the menu item
Rails.application.config.after_initialize do
  Redmine::Plugin.find(:redmine_auto_update_status).menu :admin_menu, :auto_update_rules,
                                                         { :controller => 'auto_update_rules', :action => 'index' },
                                                         :caption => :label_auto_update_status,
                                                         :html => { :class => 'icon' }
end

# Support for Redmine 5
if Redmine::VERSION::MAJOR < 6
  class ApplicationRecord < ActiveRecord::Base
    self.abstract_class = true
  end
end

module RedmineAutoUpdateStatus
  class Hooks < Redmine::Hook::ViewListener
    def view_layouts_base_html_head(context)
      stylesheet_link_tag("auto_update_status", :plugin => "redmine_auto_update_status")
    end
  end

  class ModelHook < Redmine::Hook::Listener
    def after_plugins_loaded(_context = {})
      require_relative 'project_patch'
      require_relative 'issue_patch'
    end
  end
end

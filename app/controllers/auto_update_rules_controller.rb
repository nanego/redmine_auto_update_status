class AutoUpdateRulesController < ApplicationController

  before_action :require_admin
  layout 'admin'

  def index
    @rules = AutoUpdateRule.order("id").all
  end

  def show
    @rule = AutoUpdateRule.find(params[:id])
    @initial_statuses = IssueStatus.where(id: @rule.initial_status_ids)
    @final_status = IssueStatus.find_by_id(@rule.final_status_id)

    @issues_total_count = Issue.count
    @issues_to_change = @rule.issues
    @issues_to_change_count = @issues_to_change.count
    @issues_to_change_pages = Paginator.new @issues_to_change_count, per_page_option, params[:page]
    @issues_to_change_paginated = @issues_to_change.includes(:project, :tracker, :priority, :status)
                                      .limit(@issues_to_change_pages.per_page)
                                      .offset(@issues_to_change_pages.offset)
  end

  def new
    @rule = AutoUpdateRule.new
  end

  def create
    @rule = AutoUpdateRule.new
    @rule.safe_attributes = params[:auto_update_rule]

    if @rule.save
      respond_to do |format|
        format.html {
          flash[:notice] = l(:notice_auto_update_rule_successfully_created)
          redirect_to auto_update_rules_path
        }
      end
    else
      respond_to do |format|
        format.html {render :action => :new}
      end
    end
  end

  def edit
    @rule = AutoUpdateRule.find(params[:id])
  end

  def update
    @rule = AutoUpdateRule.find(params[:id])
    @rule.safe_attributes = params[:auto_update_rule]
    if @rule.save
      respond_to do |format|
        format.html {
          flash[:notice] = l(:notice_auto_update_rule_successfully_updated)
          redirect_to auto_update_rules_path
        }
      end
    else
      respond_to do |format|
        format.html {render action: :edit}
      end
    end
  end

  def destroy
    @rule = AutoUpdateRule.find(params[:id])
    @rule.destroy
    respond_to do |format|
      format.html {
        flash[:notice] = l(:notice_auto_update_rule_successfully_deleted)
        redirect_to(:back)
      }
    end
  end

  def apply
    @rule = AutoUpdateRule.find(params[:id])
    new_issue_params = {note: @rule.note, user: @rule.author, new_status_id: @rule.final_status_id}
    if params[:issue_id]
      issue = Issue.find_by_id(params[:issue_id])
      if @rule.issues.include?(issue)
        issue.change_status(new_issue_params)
      end
    else
      if params[:apply_to_all] == 'true'
        @rule.issues.each do |issue|
          issue.change_status(new_issue_params)
        end
      end
    end

    respond_to do |format|
      format.html {
        flash[:notice] = l(:notice_auto_update_rule_successfully_applied)
        redirect_to(:back)
      }
    end
  end
end

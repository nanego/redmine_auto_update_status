class AutoUpdateRulesController < ApplicationController

  before_action :require_admin
  layout 'admin'

  def index
    @rules = AutoUpdateRule.order("id").all
  end

  def show
    @rule = AutoUpdateRule.find(params[:id])
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
end

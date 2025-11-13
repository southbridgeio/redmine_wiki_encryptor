class RedmineWikiEncryptorController < ApplicationController
  before_action :find_page, :authorize

  respond_to :js

  def change_not_index
    return render_403 unless editable?
    @page.not_index = !@page.not_index
    @page.save
  end

  private

  def find_page
    @project = Project.find(params[:project_id])
    @wiki = @project.wiki
    render_404 unless @wiki
    @page = @wiki.find_page(params[:id])
    if @page.nil?
      render_404
      return
    end
  rescue ActiveRecord::RecordNotFound
    render_404
  end

  # Returns true if the current user is allowed to edit the page, otherwise false
  def editable?(page = @page)
    page.editable_by?(User.current)
  end
end

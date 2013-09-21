require 'redmine'

class VoteController < IssuesController
  include IssuesHelper

  before_filter :find_issue
  before_filter :authorize, :except => [:up, :down]
  
  def up
    vote(:up, params[:count])
  end

  def down
    vote(:down, params[:count])
  end
  
  def clear
    if @issue.clear_votes()
      flash[:notice] = l(:label_votes_clear_succeeded)
    else
      flash[:error] = l(:label_votes_clear_failed)
    end
    
    reset_invocation_response
    respond_to do |format|
      format.html { redirect_to_referer_or }
      format.js { render :partial => 'issues/voting_controls', :locals => { :issue => @issue } }
    end
  end

  private
  def vote(type, count)
    count = Integer(count) unless count.nil?
    count = 1 if count.nil?
    if !allowed_to_vote?(@issue, type, count)
      return deny_access
    end
    
    if @issue.vote(type, count)
      success = true
    else
      print "\n\n#{@issue.errors.inspect}\n\n"
      success = false
    end
    # TODO
    reset_invocation_response
    respond_to do |format|
      format.html { 
        if success
          flash[:notice] = l(:label_votes_vote_succeeded)
        else
          flash[:error] = l(:label_votes_vote_failed)
        end
        redirect_to_referer_or(:controller => :issues, :action => :show, :id => @issue.id)
      }
      format.js { render :partial => 'issues/voting_controls', :locals => { :issue => @issue, :success => success } }
    end
    
  end

  def reset_invocation_response
    self.instance_variable_set(:@_response_body, nil)
    response.instance_variable_set(
      :@header,
      Rack::Utils::HeaderHash.new("cookie" => [], 'Content-Type' => 'text/html'))
  end
end  

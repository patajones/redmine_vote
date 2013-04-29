require 'redmine'

class VoteController < IssuesController

  skip_before_filter :authorize, :only => [:up,:down]

  def up
    vote(:up, params[:count])
  end

  def down
    vote(:down, params[:count])
  end

  private
  def vote(type, count)
    find_issue
    authorize
    count = Integer(count) unless count.nil?
    count = 1 if count.nil?
    if @issue.vote(type, count) && @issue.save
      flash[:notice] = l(:label_votes_vote_succeeded)
    else
      flash[:error] = l(:label_votes_vote_failed)
    end
    # TODO
    reset_invocation_response
    respond_to do |format|
      format.html { redirect_to_referer_or }
      format.js { render :partial => 'issues/voting_controls', :locals => { :issue => @issue } }
    end
    
  end

  def reset_invocation_response
    self.instance_variable_set(:@_response_body, nil)
    response.instance_variable_set(
      :@header,
      Rack::Utils::HeaderHash.new("cookie" => [], 'Content-Type' => 'text/html'))
  end
end  

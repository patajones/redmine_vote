require File.expand_path('../../test_helper', __FILE__)

class VoteControllerTest < ActionController::TestCase
  fixtures :projects 
  fixtures :issues
  fixtures :users
  fixtures :roles
  fixtures :members
  fixtures :member_roles
  
  def setup
    @project = Project.find(1)
    @project.enable_module!(:issue_tracking)
    @project.enable_module!(:issue_voting)
    
    @user = User.find(2)
    @request.session[:user_id] = @user.id
          
    @role = Role.find(1)
    
    @issue = @project.issues.visible.first
  end
  
  def test_up_vote_without_permission_denies_access
    post :up, :id => @issue.id, :count => 1
    assert_response 403
  end
  
  def test_down_vote_without_permission_denies_access
    post :down, :id => @issue.id, :count => 1
    assert_response 403
  end
  
  def test_up_vote_with_permission_allowed
    @role.add_permission! :vote_issue
    
    assert_difference '@issue.votes_for' do
      post :up, :id => @issue.id, :count => 1
      assert_redirected_to :controller => :issues, :action => :show, :id => @issue.id
      @issue.reload
    end
    
    assert_equal @user, Vote.last.user
  end
  
  def test_down_vote_with_permission_allowed
    @role.add_permission! :downvote_issue
    
    assert_difference '@issue.votes_against' do
      post :down, :id => @issue.id, :count => 1
      assert_redirected_to :controller => :issues, :action => :show, :id => @issue.id
      @issue.reload
    end
    
    assert_equal @user, Vote.last.user
  end
  
  def test_deny_multivote_without_permission
    @role.add_permission! :vote_issue
    
    assert_difference '@issue.votes_for', 0 do
      post :up, :id => @issue.id, :count => 2
      assert_response 403
      @issue.reload
    end
  end
  
  def test_allow_multivote_with_permission
    @role.add_permission! :vote_issue
    @role.add_permission! :multiple_vote_issue
    
    assert_difference '@issue.votes_for', 2 do
      post :up, :id => @issue.id, :count => 2
      assert_redirected_to :controller => :issues, :action => :show, :id => @issue.id
      @issue.reload
    end
    
    assert_equal @user, Vote.last.user
  end
  
  def test_deny_consecutive_votes_without_multivote_permission
    @role.add_permission! :vote_issue
    
    post :up, :id => @issue.id, :count => 1
    assert_redirected_to :controller => :issues, :action => :show, :id => @issue.id
    @issue.reload
    
    assert_difference '@issue.votes_for', 0 do
      post :up, :id => @issue.id, :count => 1
      assert_response 403
      @issue.reload
    end
  end
  
  def test_allow_consecutive_votes_with_multivote_permission
    @role.add_permission! :downvote_issue
    @role.add_permission! :multiple_vote_issue
    
    @role.add_permission! :vote_issue
    
    post :down, :id => @issue.id, :count => 1
    assert_redirected_to :controller => :issues, :action => :show, :id => @issue.id
    @issue.reload
    
    assert_difference '@issue.votes_against', 1 do
      post :down, :id => @issue.id, :count => 1
      assert_redirected_to :controller => :issues, :action => :show, :id => @issue.id
      @issue.reload
    end
  end
  
  def test_deny_consecutive_downvotes_without_multivote_permission
    @role.add_permission! :downvote_issue
        
    post :down, :id => @issue.id, :count => 1
    assert_redirected_to :controller => :issues, :action => :show, :id => @issue.id
    @issue.reload
    
    assert_difference '@issue.votes_against', 0 do
      post :down, :id => @issue.id, :count => 1
      assert_response 403
      @issue.reload
    end
  end
  
  def test_allow_consecutive_downvotes_with_multivote_permission
    @role.add_permission! :downvote_issue
    @role.add_permission! :multiple_vote_issue
    
    @role.add_permission! :vote_issue
    
    post :down, :id => @issue.id, :count => 1
    assert_redirected_to :controller => :issues, :action => :show, :id => @issue.id
    @issue.reload
    
    assert_difference '@issue.votes_against', 1 do
      post :down, :id => @issue.id, :count => 1
      assert_redirected_to :controller => :issues, :action => :show, :id => @issue.id
      @issue.reload
    end
  end
  
  def test_allow_up_then_down_vote_without_multiple_permission
    @role.add_permission! :vote_issue
    
    post :up, :id => @issue.id, :count => 1
    assert_redirected_to :controller => :issues, :action => :show, :id => @issue.id
    @issue.reload
    
    assert_difference '@issue.votes_against', 1 do
      post :down, :id => @issue.id, :count => 1
      assert_redirected_to :controller => :issues, :action => :show, :id => @issue.id
      @issue.reload
    end
  end
  
  def test_allow_down_then_up_vote_without_multiple_permission
    @role.add_permission! :downvote_issue
    
    post :down, :id => @issue.id, :count => 1
    assert_redirected_to :controller => :issues, :action => :show, :id => @issue.id
    @issue.reload
    
    assert_difference '@issue.votes_for', 1 do
      post :up, :id => @issue.id, :count => 1
      assert_redirected_to :controller => :issues, :action => :show, :id => @issue.id
      @issue.reload
    end
  end
  
end

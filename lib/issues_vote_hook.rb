# Provides a link to the issue age graph on the issue index page
class IssuesVoteHook < Redmine::Hook::ViewListener
  
  render_on :view_issues_context_menu_start, :partial => 'issues/voting_context_menu'
  
  render_on :view_issues_show_details_bottom, :partial => 'issues/issue_voting'
end

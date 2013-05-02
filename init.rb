require 'redmine'
require 'issue_vote_patch'
require 'issue_query_vote_patch'
require_dependency 'issues_vote_hook'

Redmine::Plugin.register :redmine_vote do
  name 'Redmine Vote plugin'
  author 'Andrew Chaika'
  description 'Issue Vote Plugin'
  version '0.0.3'
  project_module :issue_voting do
    permission :vote_issue, {:vote => :up}, :require => :loggedin
    permission :downvote_issue, {:vote => :down}, :require => :loggedin
    permission :multiple_vote_issue, {:vote => :multiple_vote}, :require => :loggedin
    permission :view_votes, {:vote => :view_votes}, :require => :loggedin
    permission :clear_votes, {:vote => :clear}, :require => :loggedin
  end
end

class RedmineVoteListener < Redmine::Hook::ViewListener
  render_on :view_layouts_base_html_head, :inline => "<%= stylesheet_link_tag 'stylesheet', :plugin => 'redmine_vote' %>"
end 

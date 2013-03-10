require_dependency 'issue_query'

module QueryVotePatch
  def can_vote?(context = {})
    context[:project].module_enabled?('issue_voting') and User.current.allowed_to?(:view_votes, context[:project])
  end
  
  def available_columns_with_votes_value
    columns = available_columns_without_votes_value
    columns << QueryColumn.new(:votes_value, :sortable => "#{Issue.table_name}.votes_value")  unless columns.detect{ |c| c.name == :votes_value }
    columns
  end

  def self.included(base)
    base.send :alias_method_chain, :available_columns, :votes_value
  end
end

IssueQuery.send :include, QueryVotePatch

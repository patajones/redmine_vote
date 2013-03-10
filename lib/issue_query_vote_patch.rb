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
  
  def initialize_available_filters_with_votes_filter
    initialize_available_filters_without_votes_filter
    add_available_filter "votes_value",
      :type => :integer, :values => IssueStatus.sorted.all.collect{|s| [s.name, s.id.to_s] }
  end

  def self.included(base)
    base.send :alias_method_chain, :available_columns, :votes_value
    base.send :alias_method_chain, :initialize_available_filters, :votes_filter
  end
end

IssueQuery.send :include, QueryVotePatch

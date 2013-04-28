class IssuesAddVotesPercent < ActiveRecord::Migration
  def self.up
    add_column :issues, :votes_percent, :double, :default => 0, :null => false
    
    Issue.reset_column_information
    Issue.all.each do |issue|
      issue.update_attributes!(:votes_percent => issue.votes_percent)
    end
  end

  def self.down
    remove_column :issues, :votes_percent
  end
end
class IssuesAddVotesPercent < ActiveRecord::Migration
  def self.up
    add_column :issues, :votes_percent, :double, :default => 0, :null => false
  end

  def self.down
    remove_column :issues, :votes_percent
  end
end
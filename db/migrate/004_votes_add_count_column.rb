class VotesAddCountColumn < ActiveRecord::Migration
  def self.up
    add_column :votes, :vote_count, :integer, :default => 1, :null => false
  end

  def self.down
    remove_column :votes, :vote_count
  end
end
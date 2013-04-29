class CalculateInitialVotesValue < ActiveRecord::Migration
  def self.up
    Issue.reset_column_information
    Issue.all.each do |issue|
      votes_for = issue.votes.select{|v| v.vote}.sum(&:vote_count)
      votes_against = issue.votes.select{|v| !v.vote}.sum(&:vote_count)
      issue.update_attributes!(:votes_value => votes_for - votes_against)
    end
  end

  def self.down
  end
end
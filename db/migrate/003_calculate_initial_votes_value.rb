class CalculateInitialVotesValue < ActiveRecord::Migration
  def self.up
    Issue.reset_column_information
    Issue.all.each do |issue|
      issue.update_attributes!(:votes_value => issue.votes_for - issue.votes_against)
    end
  end

  def self.down
  end
end
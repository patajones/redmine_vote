namespace :redmine do
  namespace :redmine_vote do
    task :initialize_votes => :environment do
      Issue.reset_column_information
      Issue.all.each do |issue|
        issue.update_attributes!(:votes_value => issue.votes_for - issue.votes_against)
        issue.update_attributes!(:votes_percent => issue.votes_percent)
      end
    end
  end
end

module HelpersVotePatch
  def self.included(base)
    unloadable
    
    base.class_eval do
      def show_votes?(issue, user = User.current)
        return user.allowed_to?(:view_votes, issue.project)
      end
      
      def allowed_to_vote?(issue, type = :up, count = 1, user = User.current)
        project = issue.project
        return user.allowed_to?(:clear_votes, project) if type == :clear
        count_by_user = issue.vote_count_by_user(user)
        if type == :up
          return false if (count_by_user >= 0) and !user.allowed_to?(:vote_issue, project)
          return false if (count > 1 or (count_by_user > 0))  and !user.allowed_to?(:multiple_vote_issue, project)
        end
        if type == :down
          return false if (count_by_user <= 0) and !user.allowed_to?(:downvote_issue, project)
          return false if (count > 1 or (count_by_user < 0))  and !user.allowed_to?(:multiple_vote_issue, project)
        end 
        true
      end
    end
  end
  
end

IssuesHelper.send(:include, HelpersVotePatch)
ContextMenusHelper.send(:include, HelpersVotePatch)
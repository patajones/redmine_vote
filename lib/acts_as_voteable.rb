# ActsAsVoteable
module Juixe
  module Acts #:nodoc:
    module Voteable #:nodoc:

      def self.included(base)
        base.extend ClassMethods
      end

      module ClassMethods
        def acts_as_voteable
          has_many :votes, :as => :voteable, :dependent => :delete_all
          include Juixe::Acts::Voteable::InstanceMethods
          extend Juixe::Acts::Voteable::SingletonMethods
        end
      end
      
      # This module contains class methods
      module SingletonMethods
        def find_votes_cast_by_user(user=User.current)
          voteable = ActiveRecord::Base.send(:class_name_of_active_record_descendant, self).to_s
          Vote.find(:all,
            :conditions => ["user_id = ? and voteable_type = ?", user.id, voteable],
            :order => "created_at DESC"
          )
        end
      end
      
      # This module contains instance methods
      module InstanceMethods
        def vote( vote=:up, count=1, user=User.current )
          return false if (count == 0)
          Vote.create( :voteable => self, :vote => vote == :up, :vote_count => count, :user => user )
          self.reload
          self.update_attribute :votes_value, self.votes_value + (vote == :up ? count:-count)  
          self.update_attribute :votes_percent, votes_percent
          return true
        end
        def clear_votes
          Vote.destroy_all(:voteable_id => self)
          self.update_attribute :votes_value, 0
          self.update_attribute :votes_percent, 0
          return true;
        end
        def votes_for
          self.votes.select{|v| v.vote}.sum(&:vote_count)
        end
        
        def votes_against
          self.votes.select{|v| !v.vote}.sum(&:vote_count)
        end
        
        def votes_for_by_user(user = User.current)
          self.votes.where(:user_id => user.id).select{|v| v.vote}.sum(&:vote_count)
        end
        
        def votes_against_by_user(user = User.current)
          self.votes.where(:user_id => user.id).select{|v| !v.vote}.sum(&:vote_count)
        end
        
        def votes_count
          self.votes.sum(&:vote_count)
        end
        
        def votes_percent
          return 0.to_f if (votes_for == 0) && (votes_against == 0)
          
          votes_for.to_f / (votes_for.to_f + votes_against.to_f) * 100
        end
        
        def users_who_voted
          users = []
          self.votes.each { |v|
            users << v.user
          }
          users
        end
        
        def voted_by_user?(user=User.current)
          rtn = false
          if user
            self.votes.each { |v|
              rtn = true if user.id == v.user_id
            }
          end
          rtn
        end
        
        def vote_count_by_user(user=User.current)
          self.votes_for_by_user(user) - self.votes_against_by_user(user)
        end
      end
    end
  end
end

ActiveRecord::Base.send :include,  Juixe::Acts::Voteable #:nodoc:

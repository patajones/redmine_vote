# Provides a link to the issue age graph on the issue index page
class IssuesVoteHook < Redmine::Hook::ViewListener
  
  render_on :view_issues_context_menu_start, :inline => <<-END
  <% unless @issue.nil? %>
    <% if (authorize_for('issues', 'vote') && !@issue.voted_by_user?) || authorize_for('issues', 'multiple_vote') %>
      <li class="folder">
        <a href="#" class="submenu"><%= l(:label_votes) %></a>
        <ul>
          <li><%= context_menu_link l(:button_vote_up), {:controller => 'vote', :action => 'up',   :id => @issue }, :class => 'icon icon-vote-up', :method => 'post' %>
          <li><%= context_menu_link l(:button_vote_down), {:controller => 'vote', :action => 'down', :id => @issue  }, :class => 'icon icon-vote-down', :method => 'post' %>
        </ul>
      </li>
    <% end %>
  <% end %>
END
  
  render_on :view_issues_show_details_bottom, :inline => <<-END
    <tr><td><b>

	  <% if authorize_for('issues', 'view_votes') || authorize_for('issues', 'view_voter') || (authorize_for('issues', 'vote') && !@issue.voted_by_user?) || authorize_for('issues', 'multiple_vote') %>
		<%= l :label_votes %>:</b></td><td>
  	<% end %>

	  <% if authorize_for('issues', 'view_votes') %>
    <% vv = @issue.votes_value %>
    <%= content_tag('span', vv, :class => (vv > 0? 'votes-positive': ( vv < 0 ? 'votes-negative' : ''))) %>
	  <% end %>

    <% @project = @issue.project %>
	  <% if (authorize_for('issues', 'vote') && !@issue.voted_by_user?) || authorize_for('issues', 'multiple_vote') %>
      <%= link_to("", { :controller => 'vote', :action => 'up',   :id => @issue }, :class => 'icon icon-vote-up'  , :method => 'post') %>
      <%= link_to("", { :controller => 'vote', :action => 'down', :id => @issue }, :class => 'icon icon-vote-down', :method => 'post') %>
    <% end %>

    </td></tr>
END
end

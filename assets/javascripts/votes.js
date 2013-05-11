function vote(direction) {
	$.ajax({
		url: "../vote/" + direction + ".js?id=" + $('#vote_issue_id').val() + "&count=" + $('#vote_count').val(),
		type: 'POST',
		context: document.body
		}).success(function(transport) {
			$('#voting_controls').html(transport)
	});
}

$(document).ready(function() {
	$('#vote_up').click(function(event) {
		vote('up');
		return false; // Prevent link from following its href
	});
	
	$('#vote_down').click(function(event) {
		vote('down');
		return false; // Prevent link from following its href
	});
});
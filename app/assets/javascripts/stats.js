google.charts.load('current', {packages: ['corechart']});
google.charts.setOnLoadCallback(draw_plot);

function draw_plot() {
	var options = {
		pointSize: 2.0,
		lineWidth: 1.3,
		legend: 'none',
		hAxis: {
			format: 'MMM yyyy',
			title: 'time',
			textStyle: {
				fontSize: 8
			}
		}, vAxis: {
			title: 'total #',
			format: '0',
			minValue: 0
		}, trendlines: {
			0: {
					 tooltip: false,
				 }
		}
	}

	var chart = new google.visualization.ScatterChart(document.getElementById('n_users'));

	var data = new google.visualization.DataTable();
	data.addColumn('date', 'date');
	data.addColumn('number', 'users');
	//data.addColumn('number', 'genotypes');
	data.addRows(WEEKLY_USERS);

	chart.draw(data, options);
}

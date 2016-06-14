google.charts.load('current', {packages: ['corechart']});
google.charts.setOnLoadCallback(draw_plot);

function draw_plot() {
	var options = {
		lineWidth: 1.8,
		legend: {
			position: 'none'
		},
		hAxis: {
			format: 'MMM yyyy',
			title: 'time',
			curveType: 'function',
			textStyle: {
				fontSize: 8
			}
		}, vAxis: {
			title: 'total #',
			format: '0',
			minValue: 0
		}
	}

	var user_chart = new google.visualization.LineChart(document.getElementById('n_users'));

	var user_data = new google.visualization.DataTable();
	user_data.addColumn('date', 'date');
	user_data.addColumn('number', 'users');
	user_data.addColumn('number', 'genotypes');
	user_data.addRows(USERS_GENOS_VS_TIME);

	user_chart.draw(user_data, options);


	var pheno_chart = new google.visualization.LineChart(document.getElementById('n_phenos'));

	var pheno_data = new google.visualization.DataTable();
	pheno_data.addColumn('date', 'date');
	pheno_data.addColumn('number', 'phenotypes');
	pheno_data.addColumn('number', 'user phenotypes');
	pheno_data.addRows(PHENO_USER_PHENO_VS_TIME);

	pheno_chart.draw(pheno_data, options);
}

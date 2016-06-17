google.charts.load('current', {packages: ['corechart']});
google.charts.setOnLoadCallback(drawPlot);

function drawPlot() {
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
	};

	var userChart = new google.visualization.LineChart(document.getElementById('n_users'));

	var userData = new google.visualization.DataTable();
	userData.addColumn('date', 'date');
	userData.addColumn('number', 'users');
	userData.addColumn('number', 'genotypes');
	userData.addRows(USERS_GENOS_VS_TIME);

	userChart.draw(userData, options);


	var phenoChart = new google.visualization.LineChart(document.getElementById('n_phenos'));

	var phenoData = new google.visualization.DataTable();
	phenoData.addColumn('date', 'date');
	phenoData.addColumn('number', 'phenotypes');
	phenoData.addColumn('number', 'user phenotypes');
	phenoData.addRows(PHENO_USER_PHENO_VS_TIME);

	phenoChart.draw(phenoData, options);
}

import 'package:flutter/material.dart';
import 'package:managment/data/model/add_date.dart';
import 'package:managment/data/utlity.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class Chart extends StatefulWidget {
  int indexx;
  Chart({Key? key, required this.indexx}) : super(key: key);

  @override
  State<Chart> createState() => _ChartState();
}

class _ChartState extends State<Chart> {
  List<Add_data>? a;
  bool b = true;
  bool j = true;
  
  @override
  Widget build(BuildContext context) {
    switch (widget.indexx) {
      case 0:
        a = today();
        b = true;
        j = true;
        break;
      case 1:
        a = week();
        b = false;
        j = true;
        break;
      case 2:
        a = month();
        b = false;
        j = true;
        break;
      case 3:
        a = year();
        j = false;
        break;
      default:
    }

    // Debug: Print data info
    print('Chart Debug - Index: ${widget.indexx}');
    print('Chart Debug - Data count: ${a?.length ?? 0}');
    if (a != null && a!.isNotEmpty) {
      print('Chart Debug - Sample data: ${a![0].name}, ${a![0].amount}, ${a![0].IN}');
    }

    // Check if data is empty
    if (a == null || a!.isEmpty) {
      return Container(
        width: double.infinity,
        height: 300,
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.bar_chart,
                size: 60,
                color: Colors.grey[400],
              ),
              SizedBox(height: 16),
              Text(
                'No data available',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Add some transactions to see the chart',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[500],
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Generate chart data
    List<int> timeData = time(a!, b ? true : false);
    List<SalesData> chartData = [];
    
    for (int index = 0; index < timeData.length; index++) {
      String xValue;
      if (j) {
        xValue = b 
            ? a![index].datetime.hour.toString()
            : a![index].datetime.day.toString();
      } else {
        xValue = a![index].datetime.month.toString();
      }
      
      int yValue = b
          ? (index > 0 ? timeData[index] + timeData[index - 1] : timeData[index])
          : (index > 0 ? timeData[index] + timeData[index - 1] : timeData[index]);
      
      chartData.add(SalesData(xValue, yValue));
    }

    print('Chart Debug - Chart data points: ${chartData.length}');

    return Container(
      width: double.infinity,
      height: 300,
      child: SfCartesianChart(
        primaryXAxis: CategoryAxis(),
        primaryYAxis: NumericAxis(
          minimum: 0,
        ),
        series: <SplineSeries<SalesData, String>>[
          SplineSeries<SalesData, String>(
            color: Color.fromARGB(255, 47, 125, 121),
            width: 3,
            dataSource: chartData,
            xValueMapper: (SalesData sales, _) => sales.year,
            yValueMapper: (SalesData sales, _) => sales.sales,
            markerSettings: MarkerSettings(
              isVisible: true,
              height: 6,
              width: 6,
              color: Color.fromARGB(255, 47, 125, 121),
            ),
          )
        ],
      ),
    );
  }
}

class SalesData {
  SalesData(this.year, this.sales);
  final String year;
  final int sales;
}
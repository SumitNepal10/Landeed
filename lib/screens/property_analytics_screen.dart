import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import '../providers/property_provider.dart';
import '../models/property.dart';

class PropertyAnalyticsScreen extends StatelessWidget {
  const PropertyAnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Property Analytics'),
      ),
      body: Consumer<PropertyProvider>(
        builder: (context, propertyProvider, child) {
          final properties = propertyProvider.properties;
          
          // Calculate analytics data
          final priceTrends = _calculatePriceTrends(properties);
          final typeDistribution = _calculateTypeDistribution(properties);
          final locationDistribution = _calculateLocationDistribution(properties);
          final pricePerSqFt = _calculatePricePerSqFt(properties);
          final propertyAgeDistribution = _calculatePropertyAgeDistribution(properties);
          final priceRangeDistribution = _calculatePriceRangeDistribution(properties);
          
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildMarketTrendsCard(priceTrends),
                const SizedBox(height: 16),
                _buildTypeDistributionCard(typeDistribution),
                const SizedBox(height: 16),
                _buildLocationDistributionCard(locationDistribution),
                const SizedBox(height: 16),
                _buildAverageMetricsCard(properties),
                const SizedBox(height: 16),
                _buildPricePerSqFtCard(pricePerSqFt),
                const SizedBox(height: 16),
                _buildPropertyAgeDistributionCard(propertyAgeDistribution),
                const SizedBox(height: 16),
                _buildPriceRangeDistributionCard(priceRangeDistribution),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildMarketTrendsCard(Map<String, double> priceTrends) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Market Price Trends',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: false),
                  titlesData: FlTitlesData(
                    leftTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          return Text(priceTrends.keys.elementAt(value.toInt()));
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: priceTrends.entries.map((entry) {
                        return FlSpot(
                          priceTrends.keys.toList().indexOf(entry.key).toDouble(),
                          entry.value,
                        );
                      }).toList(),
                      isCurved: true,
                      color: Colors.blue,
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: const FlDotData(show: false),
                      belowBarData: BarAreaData(show: false),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeDistributionCard(Map<String, int> typeDistribution) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Property Type Distribution',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: PieChart(
                PieChartData(
                  sections: typeDistribution.entries.map((entry) {
                    return PieChartSectionData(
                      value: entry.value.toDouble(),
                      title: '${entry.key}\n${entry.value}',
                      color: _getColorForType(entry.key),
                      radius: 100,
                      titleStyle: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    );
                  }).toList(),
                  sectionsSpace: 2,
                  centerSpaceRadius: 40,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationDistributionCard(Map<String, int> locationDistribution) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Location Distribution',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: locationDistribution.values.reduce((a, b) => a > b ? a : b).toDouble(),
                  barTouchData: BarTouchData(enabled: false),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              locationDistribution.keys.elementAt(value.toInt()),
                              style: const TextStyle(fontSize: 10),
                            ),
                          );
                        },
                      ),
                    ),
                    leftTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  gridData: const FlGridData(show: false),
                  borderData: FlBorderData(show: false),
                  barGroups: locationDistribution.entries.map((entry) {
                    return BarChartGroupData(
                      x: locationDistribution.keys.toList().indexOf(entry.key),
                      barRods: [
                        BarChartRodData(
                          toY: entry.value.toDouble(),
                          color: Colors.blue,
                          width: 20,
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(4),
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAverageMetricsCard(List<Property> properties) {
    final averagePrice = properties.isEmpty
        ? 0
        : properties.map((p) => p.price).reduce((a, b) => a + b) / properties.length;
    
    final averageArea = properties.isEmpty
        ? 0
        : properties.map((p) => p.area).reduce((a, b) => a + b) / properties.length;
    
    final averageBedrooms = properties.isEmpty
        ? 0
        : properties.map((p) => p.bedrooms).reduce((a, b) => a + b) / properties.length;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Average Metrics',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildMetricCard('Average Price', '₹${averagePrice.toStringAsFixed(0)}'),
                _buildMetricCard('Average Area', '${averageArea.toStringAsFixed(0)} sq ft'),
                _buildMetricCard('Average Bedrooms', averageBedrooms.toStringAsFixed(1)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricCard(String title, String value) {
    return Column(
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildPricePerSqFtCard(Map<String, double> pricePerSqFt) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Price per Square Foot by Type',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: pricePerSqFt.values.reduce((a, b) => a > b ? a : b),
                  barTouchData: BarTouchData(enabled: false),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              pricePerSqFt.keys.elementAt(value.toInt()),
                              style: const TextStyle(fontSize: 10),
                            ),
                          );
                        },
                      ),
                    ),
                    leftTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  gridData: const FlGridData(show: false),
                  borderData: FlBorderData(show: false),
                  barGroups: pricePerSqFt.entries.map((entry) {
                    return BarChartGroupData(
                      x: pricePerSqFt.keys.toList().indexOf(entry.key),
                      barRods: [
                        BarChartRodData(
                          toY: entry.value,
                          color: _getColorForType(entry.key),
                          width: 20,
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(4),
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPropertyAgeDistributionCard(Map<String, int> ageDistribution) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Property Age Distribution',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: PieChart(
                PieChartData(
                  sections: ageDistribution.entries.map((entry) {
                    return PieChartSectionData(
                      value: entry.value.toDouble(),
                      title: '${entry.key}\n${entry.value}',
                      color: _getColorForAgeRange(entry.key),
                      radius: 100,
                      titleStyle: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    );
                  }).toList(),
                  sectionsSpace: 2,
                  centerSpaceRadius: 40,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceRangeDistributionCard(Map<String, int> priceRangeDistribution) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Price Range Distribution',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: priceRangeDistribution.values.reduce((a, b) => a > b ? a : b).toDouble(),
                  barTouchData: BarTouchData(enabled: false),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              priceRangeDistribution.keys.elementAt(value.toInt()),
                              style: const TextStyle(fontSize: 10),
                            ),
                          );
                        },
                      ),
                    ),
                    leftTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  gridData: const FlGridData(show: false),
                  borderData: FlBorderData(show: false),
                  barGroups: priceRangeDistribution.entries.map((entry) {
                    return BarChartGroupData(
                      x: priceRangeDistribution.keys.toList().indexOf(entry.key),
                      barRods: [
                        BarChartRodData(
                          toY: entry.value.toDouble(),
                          color: _getColorForPriceRange(entry.key),
                          width: 20,
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(4),
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Map<String, double> _calculatePriceTrends(List<Property> properties) {
    final Map<String, List<double>> monthlyPrices = {};
    final now = DateTime.now();
    
    for (var i = 0; i < 6; i++) {
      final date = DateTime(now.year, now.month - i, 1);
      final monthProperties = properties.where((p) {
        return p.createdAt.year == date.year && p.createdAt.month == date.month;
      }).toList();
      
      if (monthProperties.isNotEmpty) {
        final averagePrice = monthProperties
            .map((p) => p.price)
            .reduce((a, b) => a + b) / monthProperties.length;
        
        monthlyPrices['${date.month}/${date.year}'] = [averagePrice];
      }
    }
    
    return Map.fromEntries(
      monthlyPrices.entries.map((e) => MapEntry(e.key, e.value.first))
    );
  }

  Map<String, int> _calculateTypeDistribution(List<Property> properties) {
    final distribution = <String, int>{};
    for (var property in properties) {
      distribution[property.type] = (distribution[property.type] ?? 0) + 1;
    }
    return distribution;
  }

  Map<String, int> _calculateLocationDistribution(List<Property> properties) {
    final distribution = <String, int>{};
    for (var property in properties) {
      distribution[property.location] = (distribution[property.location] ?? 0) + 1;
    }
    return distribution;
  }

  Map<String, double> _calculatePricePerSqFt(List<Property> properties) {
    final Map<String, List<double>> pricesByType = {};
    
    for (var property in properties) {
      final pricePerSqFt = property.price / property.area;
      pricesByType[property.type] ??= [];
      pricesByType[property.type]!.add(pricePerSqFt);
    }
    
    final Map<String, double> averages = {};
    pricesByType.forEach((type, prices) {
      averages[type] = prices.reduce((a, b) => a + b) / prices.length;
    });
    
    return averages;
  }

  Map<String, int> _calculatePropertyAgeDistribution(List<Property> properties) {
    final Map<String, int> distribution = {
      '0-5 years': 0,
      '6-10 years': 0,
      '11-20 years': 0,
      '21-30 years': 0,
      '30+ years': 0,
    };
    
    final now = DateTime.now();
    for (var property in properties) {
      final age = now.year - property.yearBuilt;
      if (age <= 5) {
        distribution['0-5 years'] = (distribution['0-5 years'] ?? 0) + 1;
      } else if (age <= 10) {
        distribution['6-10 years'] = (distribution['6-10 years'] ?? 0) + 1;
      } else if (age <= 20) {
        distribution['11-20 years'] = (distribution['11-20 years'] ?? 0) + 1;
      } else if (age <= 30) {
        distribution['21-30 years'] = (distribution['21-30 years'] ?? 0) + 1;
      } else {
        distribution['30+ years'] = (distribution['30+ years'] ?? 0) + 1;
      }
    }
    
    return distribution;
  }

  Map<String, int> _calculatePriceRangeDistribution(List<Property> properties) {
    final Map<String, int> distribution = {
      'Under ₹10L': 0,
      '₹10L-₹25L': 0,
      '₹25L-₹50L': 0,
      '₹50L-₹1Cr': 0,
      '₹1Cr+': 0,
    };
    
    for (var property in properties) {
      if (property.price < 1000000) {
        distribution['Under ₹10L'] = (distribution['Under ₹10L'] ?? 0) + 1;
      } else if (property.price < 2500000) {
        distribution['₹10L-₹25L'] = (distribution['₹10L-₹25L'] ?? 0) + 1;
      } else if (property.price < 5000000) {
        distribution['₹25L-₹50L'] = (distribution['₹25L-₹50L'] ?? 0) + 1;
      } else if (property.price < 10000000) {
        distribution['₹50L-₹1Cr'] = (distribution['₹50L-₹1Cr'] ?? 0) + 1;
      } else {
        distribution['₹1Cr+'] = (distribution['₹1Cr+'] ?? 0) + 1;
      }
    }
    
    return distribution;
  }

  Color _getColorForType(String type) {
    switch (type.toLowerCase()) {
      case 'house':
        return Colors.blue;
      case 'apartment':
        return Colors.green;
      case 'land':
        return Colors.orange;
      case 'commercial':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  Color _getColorForAgeRange(String range) {
    switch (range) {
      case '0-5 years':
        return Colors.green;
      case '6-10 years':
        return Colors.lightGreen;
      case '11-20 years':
        return Colors.orange;
      case '21-30 years':
        return Colors.deepOrange;
      case '30+ years':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Color _getColorForPriceRange(String range) {
    switch (range) {
      case 'Under ₹10L':
        return Colors.green;
      case '₹10L-₹25L':
        return Colors.lightGreen;
      case '₹25L-₹50L':
        return Colors.orange;
      case '₹50L-₹1Cr':
        return Colors.deepOrange;
      case '₹1Cr+':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
} 
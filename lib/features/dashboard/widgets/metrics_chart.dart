import 'package:flutter/material.dart';
import 'package:ui_specification/core/constants/breakpoints.dart';
import 'package:ui_specification/core/theme/app_colors.dart';
import 'package:ui_specification/core/theme/app_dimensions.dart';
import 'package:ui_specification/core/utils/responsive.dart';
import 'package:ui_specification/core/widgets/custom_card.dart';

/// Simple metrics chart widget for dashboard
class MetricsChart extends StatelessWidget {
  const MetricsChart({super.key});

  @override
  Widget build(BuildContext context) {
    final data = [
      {'label': 'Today', 'value': 12.0, 'color': AppColors.primary},
      {'label': 'Tomorrow', 'value': 8.0, 'color': AppColors.success},
      {'label': 'This Week', 'value': 25.0, 'color': AppColors.warning},
      {'label': 'Next Week', 'value': 18.0, 'color': AppColors.info},
      {'label': 'This Month', 'value': 45.0, 'color': AppColors.secondary},
      {'label': 'Next Month', 'value': 32.0, 'color': AppColors.primary},
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        // Use all available space
        final availableWidth = constraints.maxWidth;
        final hasConstrainedHeight = constraints.hasBoundedHeight;
        final availableHeight = hasConstrainedHeight
            ? constraints.maxHeight
            : double.infinity;

        // Get screen width for responsive values
        final screenWidth = MediaQuery.of(context).size.width;
        final isSmallMobile = screenWidth < 400;
        final isMediumMobile = screenWidth >= 400 && screenWidth < 600;
        final isMobile = screenWidth < 600;
        final isTablet = screenWidth >= 600 && screenWidth < 1200;
        final isDesktop = screenWidth >= 1200;

        // Responsive dimensions
        final titleHeight = Responsive.value<double>(
          context: context,
          mobile: 24.0,
          tablet: 26.0,
          desktop: 28.0,
        );
        final legendHeight = Responsive.value<double>(
          context: context,
          mobile: 40.0,
          tablet: 45.0,
          desktop: 50.0,
        );
        final padding = Responsive.value<double>(
          context: context,
          mobile: AppDimensions.spacing12,
          tablet: AppDimensions.spacing12,
          desktop: AppDimensions.spacing16,
        );
        final spacing = Responsive.value<double>(
          context: context,
          mobile: AppDimensions.spacing12,
          tablet: AppDimensions.spacing12,
          desktop: AppDimensions.spacing16,
        );

        final otherHeights =
            titleHeight + legendHeight + (padding * 2) + spacing;
        final chartHeight = hasConstrainedHeight
            ? (availableHeight - otherHeights).clamp(0.0, double.infinity)
            : Responsive.value<double>(
                context: context,
                mobile: 120.0,
                tablet: 180.0,
                desktop: 250.0,
              );

        // Responsive bar width based on available width and device
        final barWidth = isMobile
            ? (availableWidth / data.length) -
                  8.0 // Fit all bars without scroll
            : (availableWidth / data.length).clamp(
                Responsive.value<double>(
                  context: context,
                  mobile: 12.0,
                  tablet: 16.0,
                  desktop: 20.0,
                ),
                Responsive.value<double>(
                  context: context,
                  mobile: 24.0,
                  tablet: 32.0,
                  desktop: 40.0,
                ),
              );

        // Responsive text sizes
        final labelFontSize = isSmallMobile
            ? 9.0
            : isMediumMobile
            ? 10.0
            : isTablet
            ? 11.0
            : 12.0;
        final titleFontSize = isSmallMobile
            ? 14.0
            : isMediumMobile
            ? 15.0
            : isTablet
            ? 17.0
            : 18.0;

        // Calculate max value for scaling
        final maxValue = data
            .map((item) => item['value'] as double)
            .reduce((a, b) => a > b ? a : b);
        final scaleFactor =
            (chartHeight - 40) / maxValue; // Leave space for labels

        final chartContent = CustomCard(
          padding: EdgeInsets.all(padding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Order Overview',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: titleFontSize,
                ),
              ),
              SizedBox(height: spacing),
              SizedBox(
                height: chartHeight,
                child: isMobile
                    ? Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: data.map((item) {
                          final value = item['value'] as double;
                          final color = item['color'] as Color;
                          final label = item['label'] as String;
                          return Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 2.0,
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Container(
                                    width: barWidth,
                                    height: value * scaleFactor,
                                    decoration: BoxDecoration(
                                      color: color,
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                  ),
                                  SizedBox(height: AppDimensions.spacing2),
                                  Text(
                                    label,
                                    style: TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: labelFontSize,
                                    ),
                                    textAlign: TextAlign.center,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      )
                    : SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: data.map((item) {
                            final value = item['value'] as double;
                            final color = item['color'] as Color;
                            final label = item['label'] as String;
                            return Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: Responsive.value<double>(
                                  context: context,
                                  mobile: 4.0,
                                  tablet: 6.0,
                                  desktop: 8.0,
                                ),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Container(
                                    width: barWidth,
                                    height: value * scaleFactor,
                                    decoration: BoxDecoration(
                                      color: color,
                                      borderRadius: BorderRadius.circular(
                                        Responsive.value<double>(
                                          context: context,
                                          mobile: 2,
                                          tablet: 3,
                                          desktop: 4,
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    height: Responsive.value<double>(
                                      context: context,
                                      mobile: AppDimensions.spacing2,
                                      tablet: AppDimensions.spacing4,
                                      desktop: AppDimensions.spacing4,
                                    ),
                                  ),
                                  SizedBox(
                                    width: barWidth + 10,
                                    child: Text(
                                      label,
                                      style: TextStyle(
                                        color: AppColors.textSecondary,
                                        fontSize: labelFontSize,
                                      ),
                                      textAlign: TextAlign.center,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ),
              ),
              SizedBox(
                height: Responsive.value<double>(
                  context: context,
                  mobile: AppDimensions.spacing6,
                  tablet: AppDimensions.spacing8,
                  desktop: AppDimensions.spacing8,
                ),
              ),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: Responsive.value<double>(
                  context: context,
                  mobile: AppDimensions.spacing12,
                  tablet: AppDimensions.spacing12,
                  desktop: AppDimensions.spacing16,
                ),
                runSpacing: AppDimensions.spacing8,
                children: [
                  _buildLegend('Today', AppColors.primary, isSmallMobile),
                  _buildLegend('Upcoming', AppColors.success, isSmallMobile),
                  _buildLegend('This Month', AppColors.warning, isSmallMobile),
                ],
              ),
            ],
          ),
        );

        return hasConstrainedHeight
            ? SizedBox(
                width: availableWidth,
                height: availableHeight,
                child: chartContent,
              )
            : chartContent;
      },
    );
  }

  Widget _buildLegend(String label, Color color, bool isSmallScreen) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: isSmallScreen ? 10 : 12,
          height: isSmallScreen ? 10 : 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        SizedBox(
          width: isSmallScreen
              ? AppDimensions.spacing2
              : AppDimensions.spacing4,
        ),
        Text(
          label,
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: isSmallScreen ? 11 : 12,
          ),
        ),
      ],
    );
  }
}

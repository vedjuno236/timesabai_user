import 'package:flutter_riverpod/flutter_riverpod.dart';

enum ViewType { tableView, heatmapDiagram }

// Provider for the view type
final viewTypeProvider = StateProvider<ViewType>((ref) => ViewType.tableView);

// Provider for tracking active buttons (optional)
final isTableViewActiveProvider = StateProvider<bool>((ref) => true);
final isHeatmapDiagramActiveProvider = StateProvider<bool>((ref) => false);


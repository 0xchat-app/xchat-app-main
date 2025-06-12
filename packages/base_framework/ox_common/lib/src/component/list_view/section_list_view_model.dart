
import 'list_view_model.dart';

class SectionListViewItem {
  const SectionListViewItem({
    required this.data,
    this.header,
  });

  final List<ListViewItem> data;
  final String? header;
}
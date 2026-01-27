/// Filter options for episode list.
enum EpisodeFilter {
  all('All'),
  unplayed('Unplayed'),
  inProgress('In Progress');

  const EpisodeFilter(this.label);
  final String label;
}

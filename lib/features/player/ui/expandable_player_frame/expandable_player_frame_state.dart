enum ExpandablePlayerFrameState {
  full,
  mini,
  dismiss;

  int get heightCode {
    switch (this) {
      case ExpandablePlayerFrameState.mini:
        return -1;
      case ExpandablePlayerFrameState.full:
        return -2;
      case ExpandablePlayerFrameState.dismiss:
        return -3;
    }
  }
}

enum ExpandablePlayerFrameState {
  max,
  min,
  dismiss;

  int get heightCode {
    switch (this) {
      case ExpandablePlayerFrameState.min:
        return -1;
      case ExpandablePlayerFrameState.max:
        return -2;
      case ExpandablePlayerFrameState.dismiss:
        return -3;
    }
  }
}

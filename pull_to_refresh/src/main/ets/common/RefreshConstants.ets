

// The state machine moves through these modes only when the scrollable
// identified by scrollableKey has been scrolled to its min or max limit.
export enum PullToRefreshIndicatorMode {
  initial, // initial state
  drag, // Pointer is down.
  armed, // Dragged far enough that an up event will run the onRefresh callback.
  snap, // Animating to the indicator's final "displacement".
  refresh, // Running the refresh callback.
  done, // Animating the indicator's fade-out after refreshing.
  canceled, // Animating the indicator's fade-out after not arming.
  error, //refresh failed
}

/// The signature for a function that's called when the user has dragged a
/// [PullToRefresh] far enough to demonstrate that they want the app to
/// refresh. The returned [Future] must complete when the refresh operation is
/// finished.
///
/// Used by [PullToRefresh.onRefresh].
export type RefreshCallback = ()=> Promise<boolean>;

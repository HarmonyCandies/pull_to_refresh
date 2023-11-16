/**
 * constant about refresh feature
 */
export class RefreshConstants {

  /**
   * refresh state tag
   */
  static readonly REFRESH_STATE_TAG = 'pull_to_refresh_notification_refresh_state_tag';

  /**
   * refresh default header height
   */
  static readonly REFRESH_HEADER_HEIGHT = 50;

  /**
   * refresh effective height
   */
  static readonly REFRESH_EFFECTIVE_HEIGHT = 1.2 * RefreshConstants.REFRESH_HEADER_HEIGHT;

  /**
   * refresh layout extra height
   */
  static readonly REFRESH_LAYOUT_EXTRA_HEIGHT = 0.1;

  /**
   * refresh header animation duration
   */
  static readonly REFRESH_HEADER_ANIM_DURATION = 440;
}

/**
 * refresh state enum
 */
export enum RefreshState {
  IDLE = 0,
  DRAGGING = 1,
  DRAGGING_REFRESHABLE = 2,
  REFRESHING = 3,
  COMPLETE = 4
}

/**
 * refresh header style enum
 */
export enum RefreshHeaderStyle {
  DEFAULT,
  CLOUD
}

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
/// [PullToRefreshNotification] far enough to demonstrate that they want the app to
/// refresh. The returned [Future] must complete when the refresh operation is
/// finished.
///
/// Used by [PullToRefreshNotification.onRefresh].
// typedef RefreshCallback = Future<bool> Function();

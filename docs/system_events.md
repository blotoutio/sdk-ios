# System Events

## Required events
Our SDK only needs to send one event by default. That is triggered when SDK loads.

#### SDK start
`sdk_start` event is triggered as soon as initialization function is called via [`initializeAnalyticsEngine`](/api.md#init) api. This allows us to record a user.


## Optional events
We support a lot more system events which you can enable via Manifest in your dashboard. Navigate to [https://[your-dashboard-url]/application/manifest]() and select application that which you are working with. In the list search for `SDK_Push_System_Events` and set the value to `1`. This will start sending optional system events as well. You can always turn them off, where you would set the value to `0`.

List of optional system events:
- App Launched
- App Resign
- App In Background
- App In Foreground
- App Orientation
- App Session Info
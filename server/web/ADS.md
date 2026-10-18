# JuicyAds placements

The website loads one display zone below the game and model selection area:

| Available width | Zone | Creative size |
| --- | --- | --- |
| 908 px or wider | 1129382 | 908 × 258 |
| 632–907 px | 1129383 | 632 × 190 |
| Below 632 px | 1129384 | 308 × 286 |

The ad lives outside the game render root. Game actions do not recreate it or
request additional impressions. Rotation scales the existing creative if needed.
An ad blocker or an unfilled zone does not prevent the puzzle from working.

Both Android projects show zone 1129384 below the home screen Play button in a
scrollable layout. They bundle `assets/juicy-banner.html` and render it in an
isolated WebView with the website as its HTTPS base URL. User-initiated HTTPS/HTTP
ad links open in the external browser. No native bridge is exposed to ad code.

All three supplied snippets are display zones. No native feed, popunder, or
rewarded-hint advertising is configured by these snippets.

Deploy the web build and rebuild/install each Android APK to release the changes.
Verify actual ad fill, clicks, and mobile-app traffic eligibility in JuicyAds and
on a physical device; compilation does not verify network-side delivery.

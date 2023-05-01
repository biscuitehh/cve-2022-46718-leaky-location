# CoreParsecLocation

**tl;dr add an entitlement check to `parsecd`**

## Overview

CoreParsecLocation is a sample application demonstrating how a third-party app can access a user's precise location without a user's consent or permission. `parsecd`/`CoreParsec` also provides information such as localized search suggestions, knowledge cards, and a temporary user ID. Thankfully, I do not believe the user ID is persisted or recycled at this time.

## Timeline
- Discovered the information leak in November 2022 & reporting the finding to Apple.
- Apple patched the issue with iOS 16.2 in December 2022.
- Apple verified that the issue was fixed in January 2023, assigned the issue with CVE-2022-46718, and paid out a bug bounty of $35,000.
- *This part bugs me a bit* The public disclosure was added to the [iOS 16.2 Security Notes](https://support.apple.com/en-us/HT213530) on May 1st, 2023.

## How does it work?

During a routine Frameworks expedition, I noticed an active `NSXPCConnection` to `parsecd`. After a few days of tinkering, I discovered that `parsecd` would respond to search queries from any application as long as I spoofed the correct header information. In this case, I used the `SPPARSession` class, which sets up a session for Spotlight.

At first, I assumed that the `PARResponse` object would only return a GeoIP location (which isn't that useful on its own). However, after trying numerous search queries, I discovered that searching for "restaurants" would cause `parsecd` to grab the user's precise location. It then returned the location information to me via the `PARReponse` object.

`parsec` also returns additional information, such as localized news results & search suggestions. I do not believe these contain any user-identifiable information at this time. After submission, I plan to further explore the additional responses.

## Important Tidbits
- The user *IS NOT* notified that their location is currently in use. I'm unsure how often `parsecd` asks for a new location, but I did not see a location indicator in the status bar during my testing.
- The location updates every 100ft or so.
- Affects iOS 16/16.0.1.
- Makes use of the third-party library `Dynamic` (found here: https://github.com/mhdhejazi/Dynamic). This library is not required to exploit `parsecd`, but it does make it easier to use third-party APIs without exposed headers.
- Requires an internet connection, although I'm still testing to see if `parsecd` will return the location without one.
- I believe this falls under the "User-Installed App: Unauthorized Access to Sensitive Data" category on https://developer.apple.com/security-bounty/payouts/.
- This code is _not my best work_ but I was very excited to submit this and wrote it at 3AM. If ya'll have any questions/comments please don't hesitate to reach out.

# Peach

Hacky utilities for Fruitz app

## Planned features

- Show amount of remaining likes somewhere
- Auto-reveal little pictures on big button above matches
- Remove all buttons of paid options (began)
- Show number of matches somewhere
- Handle profile' gifs in image opener
<!-- Find a way to show tweak version dynamically + relaunch app instead of close -->
<!-- Enable RCTDevSettings (vc.viewIfLoaded.bridge.dev{Settings,Menu} = [ new]) -->
<!-- [[RCTBridge currentBridge] reloadWithReason:nil] -->
<!-- Hook launch storyboard, fix FIXMEs -->

## History

**v1.4.1** • Peach's 1st birthday 🎉 - 03/04/2022

- New bundle id now replaces the old one in package managers
- Rework and fix logic for "Close app" button in settings
- Adapt font size of cells in settings
- Fix bio not always being detected under certain conditions
- Fix (again) end of bio getting out of its view
- Fix wrong font being applied to bio with devices using bold font

**v1.4.0** - 03/03/2022

- Add Settings pane with 10 toggles for the tweak (replaces the alert when clicking the peach icon in the app logo)
- Add haptics when long pressing to open images
- Improve haptics for button, now working much more reliably
- Improve share sheet and save button in image opener
- Filter some other characters to improve Instagram parser
- Code improvements

**v1.3.2** - 02/27/2022

- Improve Instagram finder engine
  - Fix word highlighted not where it's been found
  - Correctly handles emojis & new lines
- Change package identifier & contact email
- Slightly improved dark mode again
- Add spinners for images loading
- Add experimental haptics for like and dislike buttons
- Fix rare crash when opening profiles (thanks, emojis)
- Fix wrong font when bio starts with an emoji
- Fix end of bio getting out of its text view
- Slightly increase and standardize durations for long-press open

**v1.3.1** - 05/11/2021

- Make Dark Mode truly dark
- Add credits by tapping on the peach of the logo
- Fix rare crashes

**v1.3.0** - 05/09/2021

- Add Dark Mode support
- Prevent words like "instant" to be triggers for Instagram detection

**v1.2.4** - 04/10/2021

- Fix empty images being able to be opened in detail
- Rewrite Haptics Manager, adding support for iPhone 6 and lower

**v1.2.3** - 04/07/2021

- Disable long-press gesture for non-profile-picture images
- Improve double tap to zoom
- Add view in title indicating that Peach is loaded
- Add strong vibration for iPhone 6s

**v1.2.2** - 03/24/2021

- Add support for parenthesis in Instagram parser
- Change `@` handling

**v1.2.1** - 03/24/2021

- Make deblurring async for better performance
- Add transition and spinner for a cleaner reveal
- Add securities to prevent unexpected behavior

**v1.2.0** - 03/23/2021

- Add Instagram parser for bio

**v1.1.0** - 03/09/2021

- Add `PCHImageViewController` to see revealed images bigger

**v1.0.0** - 03/04/2021

- Initial release

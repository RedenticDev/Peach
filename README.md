# Peach

Hacky utilities for Fruitz app

## Planned features

- Remove all buttons of paid options (began)
- Haptics on like/dislike buttons (began)
- Spinner on loading images (began)
- Auto-reveal for little pictures on big button above matches
- Show number of matches somewhere
- Show amount of remaining likes somewhere
- Comprehensive in-app tweak settings pane

## History

<!-- **** - 0//2022

- Handle gif in ImageVC
- Find a way to popen
- Settings
  - Enable
  - Dark mode
  - Enable ImageVC
  - Enable unblur
  - Enable haptics
  - Enable Instagram parser
- Add auto-unblur support for little images on Basket page (?) -->

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

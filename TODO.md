# CORE FUNCTIONS
## SHOTLINES
- [x] Created Shotline data struct which holds position and metadata for each Shotline
- [x] Create other data structs to ensure the user can associate as much relevant metadata to each shot
- [x] Be able to hover over a Shotline and print its metadata in the console
  - [x] Be able to detect mouse hover over a ShotLine2D
- [x] Add ability to delete shotlines
- [x] Make inspector panel load from shotline data struct and save to data struct
  - [x] When a Shotline is created, emit a signal so that the Inspector Panel can grab focus into the first InputField
  - [x] Make inspector Panel able to write data to the shotline struct
  - [x] Able to select different ShotLines and have each one populate the Inspector Panel fields
- [x] Show a Shot Number at the top of each Shotline2D
- [ ] !!!!!!!!!!BUG --------------------- Deleting shot lines is not actually working properly; the problem is likely to do with the shotline indexing system; shotlines should be indexed with UUIDs probably; as of now, deleting shotlines in a particular order means that reloading the page, the shotlines that are deleted or remaining may not reflect the user's clicking and clear intention
- [ ] Add ability to create squiggle sections in the middle of lines (unfilmed areas, useful for OTS / shot-reverse shot)
- [ ] Add ability to resize shotlines
- [ ] Make Shotlines able to be multipage
- [ ] Add ability to move shotlines horizontally and vertically (horizontally will be somewhat trivial, vertically a tad tricker)

## INPUT FIELDS
- [ ] Add script to LineEdit of the InputField so that changing Focus via tabbing / navigating actually works properly
- [ ] Make InputFields (and therefore their LineEdit children) ignore input with mods (while holding ctrl, alt, etc.)

## SAVING AND LOADING DOCUMENT
- [ ] Create save and load mechanism for ShotLiner shotline data (probably just json tbh)

# QUALITY OF LIFE
- [ ] Add Tooltips when hovering over ShotLines
- [ ] Highlight all `Label`s that are encompassed by the currently highlighted ShotLine
- [ ] Draw "preview" Line2D as the user is drawing with the mouse
- [ ] Keyboard-Only input mode (Make the layout normie friendly) (or just have the ability to rebind keys in a settings menu)
- [ ] Show un-lined screenplay lines highlighted in red (the Labels for unmarked lines)
- [ ] Have InputFields give autocomplete suggestions for default or already registered values (Shot Numbers, Shot Types, tags, props, everything)

# SOFTWARE / UX LANGUAGE

* there are too many things called "lines" lmao it hurts my fuckin brain
 - ShotLine is kinda good to describe the vertical lines that represent shots
 - We could just refer to the lines of the screenplay as, y'know, lines
 - perhaps it might be better to call the vertical lines something else for maximum clarity
	- "Traces" - implies an outline, or a plan, which is appropriate for creating a shotlist
	- "Strips" - has a nice connotation with "film strips" but not enough overlap to be egregious imo
	- "Streaks" - eh
	- "Threads" - eh
	

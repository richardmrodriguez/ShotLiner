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
- [ ] Add ability to move shotlines horizontally and vertically (horizontally will be somewhat trivial, vertically a tad tricker)
- [ ] Make Shotlines able to be multipage
- [ ] Add ability to resize shotlines

### SHOTLINE SHORTCUTS
- [ ] Add a button which takes one line which has squiggles and create an equal and opposite line with inverted squiggle sections
  - i.e. if I create a shot which spans from lines 1 to 10, but has squiggles from 6 to 10, this creates a new line spanning 1 to 10, but the new line has squiggles from 1 to 5
- [ ] add ability to auto- squiggle a line by clicking on a CHARACTER name to include / exclude them from that line
    - This should not supercede the ability to manually adjust squiggles (a character may walk off camera for a shot then walk back on camera for example) 
- [ ] Create a Shotline covering entire scene just by clicking on the Scene Heading

## INPUT FIELDS
- [ ] Add script to LineEdit of the InputField so that changing Focus via tabbing / navigating actually works properly
- [ ] Make InputFields (and therefore their LineEdit children) ignore input with mods (while holding ctrl, alt, etc.)

## SAVING AND LOADING DOCUMENT
- [ ] Create save and load mechanism for ShotLiner shotline data (probably just json tbh)
- [ ] !!! Ability to Export to an excel spreadsheet (entire point of the entire software lmao)

# QUALITY OF LIFE
- [ ] Add Tooltips when hovering over ShotLines
- [ ] Highlight all `Label`s that are encompassed by the currently highlighted ShotLine
- [ ] Draw "preview" Line2D as the user is drawing with the mouse
- [ ] Keyboard-Only input mode (Make the layout normie friendly) (or just have the ability to rebind keys in a settings menu)
  -  I can imagine using a rotary encoder mapped to arrow keys (or just the mouse wheel) to quickly scroll through lines, then using a button to start drawing a line, then scrolling until the desired end line, then clicking the button again to end the line
  -  This could actually be significant for either speed and efficiency or accessibilty
- [ ] Show non-covered screenplay lines highlighted in red
- [ ] Have InputFields give autocomplete suggestions for default or already registered values (Shot Numbers, Shot Types, tags, props, everything)
- [ ] Focus Mode - lets user darken all lines which are not part of the currently focused scene? eh
- [ ] Have ShotLines width be skinny by default, but fatter when focused or hovering over

# V2.0 FEATURES
- [ ] Image support
  - [ ] Ability to create storyboard from shotliines file
  - [ ] Ability to drag-drop images onto ShotLiner ( or manually add from file explorer) to create ShotLines with attached storyboard images

# SOFTWARE / UX LANGUAGE

## SEMANTICS AND EDGE CASES

* What about Shots that span multiple scenes? What then, nerd?
  * Probably a func that can look at the lines which a ShotLine spans, and determine how many scenes are covered by that ShotLine tbh

* there are too many things called "lines" lmao it hurts my fuckin brain
 - ShotLine is kinda good to describe the vertical lines that represent shots
 - We could just refer to the lines of the screenplay as, y'know, lines
 - perhaps it might be better to call the vertical lines something else for maximum clarity
	- "Traces" - implies an outline, or a plan, which is appropriate for creating a shotlist
	- "Strips" - has a nice connotation with "film strips" but not enough overlap to be egregious imo
	- "Streaks" - eh
	- "Threads" - eh
	

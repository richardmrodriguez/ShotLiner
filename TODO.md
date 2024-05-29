# CORE FUNCTIONS

## RELATIVE POSITION / PAGE 
- [ ] The Page view needs to be resizable, particularly so the user can zoom the page view in and out.

## WEIRD / SPECIFIC GODOT QUESTIONS
- When I click on the TopMarginRegion: ColorRect, hold the mouse button, and move the mouse across the page, the other elements in the page don't receive mouse movement updates. When I click on a Label, and then drag the mouse across the other labels, the other labels can receive mouse movement, and their scripts highlight each Label as I drag across. When I click on the ColorRect, and then drag across the page, The last highlighted Label stays stuck, and no other Labels get highlighted as I move across the page. I don't know why this happens. I need this to not happen, so that a user can draw a ShotLine that begins on the previous page.

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
- [x] Shotlines are now assigned a UUID to ensure we are always addressing the correct Shotline objects in the code
- [x] ScreenplayLine nodes can now be addressed by the FNLine UUID instead of simplistic child index
- [x] Improved spacing on begin cap and end cap regions of lines
- [ ] LAYER SELECTION DROPDOWN - the godot editor has a beautiful feature -- if you click in the scene view over a stack of many layers of nodes, it pops up a little dropdown so you can actually select the layer you want to manipulate. This would be good to have
- [ ] Implement ShotLine modification ability
  - [ ] Add different grab regions to a shotline
  	- Top endpoint
  	- Bottom endpoint
  	- Body (middle, default)
	- [x] Endcaps are just Line2Ds which are children of the EndcapGrabRegion nodes
	- [x] While creating a shotline, dragging the mouse above or below the margin makes the shotline Multipage
	- [x] Changed shotline construction and storage to rely on directly indexing page number and line number instead of only referencing the"current" pagelines
  	- [x] Shotlines structs are organized at the top EditorView level instead of by the ScreenplayPage node, all previous functionality appears to be working 
  	- [x] Shotlines can have Open or Closed endcaps
	- [x] Shotline2D Nodes can be moved my click dragging
	- [ ] When a Shotline Node is moved, it should do the following:
	  - [ ] auto-snap its vertical end points to the nearest Label coordinates
	  - [x] update the Shotline data struct to reflect this new position
	  - [ ] if while dragging the shotline body, the top or bottom ends up higher than the top line or lower than the bottom line, clip the line to fit
		- [x] only make the line multipage if creating the line past the top or bottom margins
		- [ ] if the line is already multipage (say, the line continues only down to the next page), when dragging the line body, the bottom of the line stays at the bottom of the page while the line itself moves horizontally, and the line top moves vertically
  - [ ] Make Shotlines able to be multipage
  	- [ ] Add Signals to begin cap and end cap grab regions
  - [ ] Each Scene has a Shot Count that is updated whenever a new ShotLine is added that covers a particular scene
  - [ ] RESIZE shotlines by clicking and dragging top or bottom endpoints
  	- [ ] ShotLines are extended to the next page by dragging a shotline's endpoint down past the final line of the page and into the margin
  	  - Maybe have a ColorRect which appears at the bottom of the page when dragging, to indicate to the user that they are about to make a multipage line
  	  - When user lets go of line, the page automatically changes to the next page so the user can continue dragging the line
  	  - A more elegant solution should exist to acommodate lengthy, multipage oners at some point...
  - [ ] Add ability to create squiggle sections in the middle of lines (unfilmed areas, useful for OTS / shot-reverse shot)
- [ ] Make it so that Shotlines CANNOT share the same Shot Numbers (specificially Scene Number AND Shotnumber)
- [x] Refactored Shotline deletion behavior to be handled by EditorView script
  - [x] Implemented logic to determine if a mouse button release is actually happening over a particular ShotLine node
- [ ] Have a floating tooltip which follows the mouse whenever the mouse is hovering over the ShotLine, which displays the ShotLine's Scene Number
  - The user should never have to scroll or scan up and down the page to figure out which ShotLine they are touching or manipulating
- [ ] Have the Mouse Cursor change based on which action is taking place

### SHOTLINE SHORTCUTS
- [ ] Add a button which takes one line which has squiggles and create an equal and opposite line with inverted squiggle sections
  - i.e. if I create a shot which spans from lines 1 to 10, but has squiggles from 6 to 10, this creates a new line spanning 1 to 10, but the new line has squiggles from 1 to 5
- [ ] add ability to auto- squiggle a line by clicking on a CHARACTER name to include / exclude them from that line
	- This should not supercede the ability to manually adjust squiggles (a character may walk off camera for a shot then walk back on camera for example) 
- [ ] Create a Shotline covering entire scene just by clicking on the Scene Heading

## INPUT FIELDS & INSPECTOR PANEL
- [x] Add script to LineEdit of the InputField so that changing Focus via tabbing / navigating actually works properly
- [x] Shot Num is auto populated with "0" if tabbed in or out while the LineEdit is empty
- [ ] Autopopulate new ShotLine with most recent (i.e. highest number) Scene num, then grab focus on ShotNum field
- [ ] Make InputFields (and therefore their LineEdit children) ignore input with mods (while holding ctrl, alt, etc.)
  - specifically, if I press ctrl or alt while a field is highlighted, it should not enter text into the field

## SAVING AND LOADING DOCUMENT
- [ ] Create save and load mechanism for ShotLiner shotline data (probably just json tbh)
- [ ] !!! Ability to Export to an excel spreadsheet (entire point of the entire software lmao)

## OTHER TOOLS

### SELECTION TOOL
- [ ] Need a recangle lasso tool to select multiple shotlines at once
  - [ ] This probably also requires a more robust state machine to handle the different interface modes (drawing vs selection and moving)
  - [ ] Ability to edit the metadata of multiple ShotLines at once
  - [ ] Only overwrites modified fields for selected ShotLines, leaves unmodified individual fields alone 
- [ ] Eraser tool - click and drag across the page to delete any ShotLines that cross under the mouse cursor
  - Very necessary for quickly erasing many shotlines at once
## USER INPUT
- [ ] Keyboard-Only input mode (Make the layout normie friendly) (or just have the ability to rebind keys in a settings menu)
  -  I can imagine using a rotary encoder mapped to arrow keys (or just the mouse wheel) to quickly scroll through lines, then using a button to start drawing a line, then scrolling until the desired end line, then clicking the button again to end the line
  -  This could actually be significant for either speed and efficiency or accessibilty
-  [ ] Control-Tab cycles through the ShotLine selection on the page

# QUALITY OF LIFE / BONUS
- [x] Have ShotLines width be skinny by default, but fatter when focused or hovering over
- [ ] Ability to filter out (fade out or gray out) Shotlines of a certain kind
  - Filter by:
	- Scene
	- Shot type (wide, medium close)
	- Lens Type
	- etc.
  - This allows someone to focus say only on pickups or extreme closeups
  - Conversely, you could filter out all the smaller shots and see what your wider shots give you in terms of coverage
- [ ] Have ShotLines automatically space themselves apart horizontally so they don't overlap
- [ ] When hovering over a ShotLine, make the Scene Number label also display Shot Type and Setup # under the scene number
- [ ] Button that changes what the Scene Number Label displays over all the Shotlines
  - Scene Number (scene.shot)
  - Setup Number
  - Shot type
- [ ] Draw "preview" Line2D as the user is drawing with the mouse
- [ ] When drawing Shotlines, have new lines be automatically numbered by the scene number of the above Scene Heading
  - i.e. if I draw a new line underneath a scene heading INT. HOUSE - NIGHT, and that's scene 2, the new shotline will automatically have the scene number 2
- [ ] Highlight all `Label`s that are encompassed by the currently highlighted ShotLine
- [ ] Show non-covered screenplay lines highlighted in red
- [ ] Have InputFields give autocomplete suggestions for default or already registered values (Shot Numbers, Shot Types, tags, props, everything)
- [ ] ? - Focus Mode - lets user darken all lines which are not part of the currently focused scene? eh
- [ ] ? - ShotLine redundancy?
  - Maybe have the ability to have a single shotline be marked as multiple shotlines 
  - If you know you're going to have a flashback for example, and you know you're going to use exact shots from an earlier scene, you can mark those shots from that later scene as done when you film it the first time
- [ ] Add Tooltips when hovering over ShotLines
  - But what would these tooltips be though lmao

# V2.0 FEATURES
- [ ] Image support
  - [ ] Ability to create storyboard from shotliines file
  - [ ] Ability to drag-drop images onto ShotLiner ( or manually add from file explorer) to create ShotLines with attached storyboard images
- [ ] "On-Set" Mode
  - [ ] "ghost editing" like racing a mario kart ghost
	- You can choose to simply check off pre-drawn ShotLines or add your own as you go
	- You can see where you may be deviating from your pre-lined script with your new lining
  - [ ] Quick lining controls (see the Quality of Life section)
	- [ ] Gamepad support
	- [ ] Touch Screen support
- [ ] Android / iOS tablet support (tricky with godot-rust, might have to do a full rewrite of the fountain parser in gdscript)

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
	

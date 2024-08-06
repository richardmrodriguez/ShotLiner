- # Feature Roadmap

- ## v1.0 
  These are features that are critical to the eventual 1.0 release:  
  
	- ## 0.2.0 - DONE

		- **Proper PDF Element Parsing**

			- This is necessary and mandatory for being able to automatically assign scene numbers to shotlines

		- **Quality of Life / Workflow Efficiency**

			- Auto-populate ShotLine fields with relevant metadata

				- Automatic nominal scene number detection

				- Automatically assign next shot number in sequence when creating multiple shotlines

	- ## 0.3.0 - DONE

		- **User Input**

			- Abstract user input using Godot input mapping, prepare for touch-screen based input

			- Add basic keyboard shortcuts

				- `Ctrl`+`Z` - Undo

				- `Ctrl`+`Shift`+`Z` - Redo

				- `Ctrl`+`I` - Import PDF

				- `Ctrl`+`S` - Save to ShotLiner (.sl) Document

				- `Ctrl`+`O` - Open ShotLiner (.sl) Document

				- `Ctrl`+`E` - Export to CSV

			- Shotline Control Change

				- Hold `Alt` while drawing to invert filmed segments of shotlines, instead of right click

	- ## 0.4.0

		- **User Input**

			- Intuitive Touchscreen Controls (i.e. for Android or iOS, but could also include Windows or Linux tablet support)

			-

		- **UX / Workflow**

			- Auto-populate shot TYPE (WIDE, MEDIUM, CLOSEUP, etc.) based a dropdown and/or radial menu that pops up after drawing each shotline

			- Right click menu on shotline with option "Duplicate inverted" for instantly creating a shotline with the opposite filmed / unfilmed segments

				- Change (segment film toggle) from right-click to ctrl click

		- **Manually Change Document Elements**

			- Right click a page line and assign a line type (I.e. force a scene heading, action, dialogue, etc.)

			- Allow user to re-map margins using ruler lines

		- **Slate Number Compatibility**

			- Add in support for alphabetical / alphanumeric shot numbers

				- i.e. When filming on set, shots are not numbered numerically, but alphabetically

					- "Scene 1-alpha, take one" - 1A

					- "Scene 36-Bravo, take seven" - 36B

					- etc.

			- Make sure to EXCLUDE these letters (but maybe have an option in settings to restore these letters):

				- I

				- O

				- Y

				- Z

		- **Exports**

			- Blank storyboard template

				- Each frame will correspond to a shotline, and will include metadata next to the frame like shot type, lens mm, setup #, etc.

				- Requires viewport and/or PDF export shenanigans which is haaaaard

				-

	- ## 0.5.0

		- **Exports**

			- Filterable output based upon scenes or tags

				- For example, export a CSV with only certain categories of shots:

					- Only wide shots

					- Only particular setups or groups of setups

					- Only shots

				- Output multiple CSVs, per filter

				- Output custom shotlists from a custom shooting schedule

		- **Shotline reordering**

			- Add up/down arrows to re-assign a shotline new shot number relative to other shot lines per scene

	- ## 0.6.0

	- ## 0.7.0

		- **UX**

			- Continuous Scroll-through pages view

			- Zoomable page view

			- UI Scaling

	- ## 0.8.0

		- **General Script Breakdown**

			- Document highlighting / Tagging

				- Generate reports on screenplay based upon occurrences of tagged elements like props, stunts, special effects, actors, etc.s

			- User registered / searchable tags

				- i.e. User can create their own shotline-specific tags such as "Magnifying glass prop" or "Big car VFX" and then assign those tags to shotlines

				- Can recall and re-use existing user tags to new shotlines

				- Shotlines that cover highlighted page elements have those highlighted elements automatically added as page tags

				- Can search and filter based upon tags:

					- Shotlines

					- Pages

					- Scenes

				- "User-Tag-able" Items:

					- Scenes (Scene Headings)

					- Shotlines

		-

	- ## 0.9.0 (?)
	  This is major and critical, but the most complex problem, technically  
  
		- Screenplay Draft merge-forward

			- Ability to merge current shotlines onto a new draft of the screenplay

			- Because Shotliner stores each pageline with a unique UUID, it should be feasible to diff the current screenplay content with a newly imported draft.

			- Shotlines that are only on excised pages will be simply removed, but perhaps with a warning or "ghost" shotline to show what was lost

			- Some shotlines may be partially cut off, i.e. start on a deleted page but end on a page that is not excised.

				- these shotline fragments will be marked with a special color or outline or label, so the user can intervene manually

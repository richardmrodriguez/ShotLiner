# ShotLiner
## A screenplay lining tool built with Godot 4.2

ShotLiner is a free and open-source tool for creating shotlists from a screenplay PDF.

The current alpha release is 0.1.1, and provides barebones, basic functionality.

I am currently developing this solo, and would greatly appreciate any and all feedback. Please open a GitHub issue, or send me an e-mail for a feature request or bug report: 

`richardmamarilrodriguez@gmail.com`

## Current Features
- Import any screenplay-formatted PDF
- Create multiple ShotLines per page
  - Resize shotline using Move tool
	- Shotlines can be Multipage, and span across many pages
  - A Shotline will have a Closed or Open endcap at each end, to visually distinguish which lines start or end on a previous or following page
  - Click on individual Shotlines to assign unique metadtata
  - delete Shotlines by using eraser tool
  - Click and drag Shotlines to move them horizontally
  	- When dragged to a new x-position, Shotlines retain that position when the page is refreshed
  - Right-click drag over the body of a Shotline to toggle filmed (Straight line) or unfilmed (jagged line) segments
- Save and Load document and shotline data to .sl file
- Can export shotlines and metadata to a CSV file
- Use Toolbar to select either Draw, Erase, or Move tool
- Can Undo and Redo the following:
  - Navigate Pages
  - Draw shotlines
  - Erase Shotlines
  - Toggle Filmed/ unfilmed sections of shotlines (Straight or Jagged lines)
  - Resize shotlines
  - Move shotlines horizontally on page


## Feature Roadmap

### v1.0 
These are features that are critical to the eventual 1.0 release:
- Keyboard Shortcuts
- Document highlighting / Tagging
- User registered / searchable tags
  - i.e. User can create their own tags such as "Magnifying glass prop" or "Big car VFX" and then recall them from a drop-down menu
- Quality of Life
  - Auto-populate ShotLine fields with relevant metadata
	- Automatic nominal scene number and page number detection
	- Automatically assign next shot number in sequence
- Filterable output based upon scenes or tags
  - Export only a CSV of chosen, relevant shots

### v2.0
Some of these features may not be implemented until a 2.x release.

- Screenplay Draft merge-forward
  - Ability to merge current shotlines onto a new draft of the screenplay
	- Because Shotliner stores each pageline with a unique UUID, it should be feasable to diff the current screenplay content with a newly imported draft. 
	- Shotlines that are only on excised pages will be simply removed, but perhaps with a warning or "ghost" shotline to show what was lost
	- Some shotlines may be partially cut off, i.e. start on a deleted page but end on a page that is not excised.
	  - these shotline fragments will be marked with a special color or outline or label, so the user can intervene manually

## DEPENDENCIES / ATTRIBUTION
- [PdfPig](https://github.com/UglyToad/PdfPig)
  - This Library is used to ingest PDF text content, including the exact position of each character or grapheme on a page
- [godot-uuid](https://github.com/binogure-studio/godot-uuid)

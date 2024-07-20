# ShotLiner
## A screenplay lining tool built with Godot 4.2

This tool is in pre-alpha, and is essentially a proof-of-concept until a proper mechanism for importing various documents is implemented.

## CURRENT STATUS
### 2024 - 06 - 20

This tool is in the middle of a major refactor, to support PDF Document import. Before this, some of the features listed below were in fact working, but this refactor is currently breaking most of these for the time being.

- Drawing shotlines makes them the correct height again
- Resizing shotlines needs to be refactored still
- Multipage Shotlines needs to be refactored still

## Current Features
- Navigate between individual pages
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

## Not Yet Implemented
- Spreadsheet Export
  - This is the big feature -- After creating your shotlines, you will be able to export a Shot List from your shotlines. This will be a spreadsheet with cells containing the relevant metadata for each Shot:
	- Shot Number
	- Shot Type / Subtype (Wide Shot, OTS, etc.)
	- Setup Number
	- Group Number
	- Location & Time of Day
	- misc. tags
- Document import
  - TODO: Import a document from any screenplay-formatted PDF file
  - as of right now, this tool just reads from an fountain formatted file with several caveats:
  - The Fountain parser used does not natively handle things like `*emphasis*` with asterisks
  - This also does not handle automatic pagination; for immediate testing purposes, the fountain file I am using is manually pre-paginated and has manual page breaks using  `===` delimiters.
- Select Tool button does nothing

## Backburner / Roadmap
These are features that are significant, but will not be taking focus until a stable 1.0 version is released.

Some of these features may not be implemented until a 2.x release.

- Screenplay Draft merge-forward
  - Ability to merge current shotlines onto a new draft of the screenplay
	- Because Shotliner stores each pageline with a unique UUID, it should be feasable to diff the current screenplay content with a newly imported draft. 
	- Shotlines that are only on excised pages will be simply removed, but perhaps with a warning or "ghost" shotline to show what was lost
	- Some shotlines may be partially cut off, i.e. start on a deleted page but end on a page that is not excised.
	  - these shotline fragments will be marked with a special color or outline or label, so the user can intervene manually
	- This will be crucial for real production use.

## DEPENDENCIES
- [PdfPig](https://github.com/UglyToad/PdfPig)
  - This Library is used to ingest PDF text content, including the exact position of each character or grapheme on a page
- [godot-uuid](https://github.com/binogure-studio/godot-uuid)

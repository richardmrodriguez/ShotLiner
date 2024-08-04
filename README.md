# ShotLiner
## A screenplay lining tool built with Godot 4.2

ShotLiner is a free and open-source tool for creating shotlists from a screenplay PDF.

## Current Release: 0.2.0

New in 0.2.0:

- Auto-populate ShotLine fields with Scene Number and Shot Numbers
				- Automatic nominal scene number detection
				- Automatically assign next shot number in sequence when creating multiple shotlines 


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



## DEPENDENCIES / ATTRIBUTION
- [PdfPig](https://github.com/UglyToad/PdfPig)
  - This Library is used to ingest PDF text content, including the exact position of each character or grapheme on a page
- [godot-uuid](https://github.com/binogure-studio/godot-uuid)

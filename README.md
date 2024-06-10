# ShotLiner
## A screenplay lining tool built with Godot 4.2

This tool is in pre-alpha, and is essentially a proof-of-concept until a proper mechanism for importing various documents is implemented.

## What's working so far
- Navigate between individual pages
- Create multiple ShotLines per page
  - Resize shotline using Move tool
  - Shotlines can be resized to span across multiple pages
  - A Shotline will have a Closed or Open endcap at each end, to visually distinguish which lines start or end on a previous or following page
  - Click on individual Shotlines to assign unique metadtata
  - delete Shotlines by using eraser tool
  - Click and drag Shotlines to move them horizontally
  	- When dragged to a new x-position, Shotlines retain that position when the page is refreshed
  - Right-click drag on segments of Shotline to toggle filmed (Straight line) or unfilmed (jagged line) (not fully working; see below)
- Use Toolbar to select either Draw, Erase, or Move tool
- Create multipage Shotlines (kind of)
  - When creating a Shotline, you can drag the mouse past the top or bottom margins to make the line either start on the previous page or end on the following page
- Can Undo and Redo some things:
  - Navigate Pages
  - Draw shotlines
  - Toggle Filmed/ unfilmed sections of shotlines (Straight or Jagged lines)
  - Move shotlines horizontally on page
  - Resize shotlines

## What's NOT working so far
- Creating squiggled lines for unfilmed sections is bugged; not yet saving metadata properly across pages
- Spreadsheet Export
  - This is the big feature -- After creating your shotlines, you will be able to export a Shot List from your shotlines. This will be a spreadsheet with cells containing the relevant metadata for each Shot:
	- Shot Number
	- Shot Type / Subtype (Wide Shot, OTS, etc.)
	- Setup Number
	- Group Number
	- Location & Time of Day
	- misc. tags
- Document import
  - as of right now, this tool just reads from a fountain formatted file with several caveats:
  - The Fountain parser used does not natively handle things like `*emphasis*` with asterisks
  - This also does not handle automatic pagination; for immediate testing purposes, the fountain file I am using is manually pre-paginated and has manual page breaks using  `===` delimiters.
- Select Tool button does nothing
- Shotline details
  - Moving multipage shotlines is broken at the moment
  - No option to resize shotlines yet

## DEPENDENCIES
- [Fountain Parser GDExt](https://github.com/richardmrodriguez/fountain-parser-gdext)
  - This is a wrapper for my also-WIP `fountain-parser-rs` ; this simply provides very basic fountain parsing.
- [godot-uuid](https://github.com/binogure-studio/godot-uuid)

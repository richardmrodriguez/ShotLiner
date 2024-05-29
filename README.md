# ShotLiner
## A screenplay lining tool built with Godot 4.2

This tool is in pre-alpha, and is essentially a proof-of-concept until a proper mechanism for importing various documents is implemented.

## What's working so far
- Navigate between individual pages
- Can create multiple ShotLines per page
- Can click on individual Shotlines to assign unique metadtata
- Can use Toolbar to select either Draw, Erase, or Move tool
- Can delete Shotlines by using eraser tool
- Can click and drag Shotline Nodes
  - When dragged to a new position, Shotlines retain that position when the page is refreshed
- Can create multipage Shotlines (kind of)
  - When creating a Shotline, you can drag the mouse past the top or bottom margins to make the line either start on the previous page or end on the following page
  

## What's NOT working so far
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
- Multipage Shotline details
  - Moving multipage shotlines is broken at the moment
  - There isn't a visual difference between multipage and single page shotlines yet; Multipage shotlines should use the inverted triangle endcap to indicate if it begins on an earlier page or ends on a later page

## DEPENDENCIES
- [Fountain Parser GDExt](https://github.com/richardmrodriguez/fountain-parser-gdext)
  - This is a wrapper for my also-WIP `fountain-parser-rs` ; this simply provides very basic fountain parsing.
- [godot-uuid](https://github.com/binogure-studio/godot-uuid)

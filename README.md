# ShotLiner
## A screenplay lining tool built with Godot 4.2

This tool is in pre-alpha, and is essentially a proof-of-concept until a proper mechanism for importing various documents is implemented.

## What's working so far
- Navigate between individual pages
- Can create multiple ShotLines per page
- Can create specific metadata for each line

## What's NOT working so far
- Document import
  - as of right now, this tool just reads from a fountain formatted file
  - The Fountain parser used does not natively handle things like `*emphasis*` with asterisks
  - This also does not handle automatic pagination; for immediate testing purposes, the fountain file I am using is manually pre-paginated and has manual page breaks using  `===` delimiters.
- Deleting shotlines via right-click is finnicky
  - ShotLines are indexed very simply by their object number; this should be replaced by using UUIDs. Otherwise, deleting multiple shotlines can result in unexpected and unintended deletions. 

## DEPENDENCIES
- Fountain Parser GDExt
-   This is a wrapper for my also-WIP `fountain-parser-rs` ; this simply provides very basic fountain parsing.

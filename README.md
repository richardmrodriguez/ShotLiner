# ShotLiner
## A screenplay lining tool built with Godot 4.2

This tool is in pre-alpha, and is essentially a proof-of-concept until a proper mechanism for importing various documents is implemented.

## What's working so far
- Navigate between individual pages
- Can create multiple ShotLines per page
- Can click on individual Shotlines to assign unique metadtata
- Can delete Shotlines by rigth-clicking

## What's NOT working so far
- Document import
  - as of right now, this tool just reads from a fountain formatted file
  - The Fountain parser used does not natively handle things like `*emphasis*` with asterisks
  - This also does not handle automatic pagination; for immediate testing purposes, the fountain file I am using is manually pre-paginated and has manual page breaks using  `===` delimiters.


## DEPENDENCIES
- [Fountain Parser GDExt](https://github.com/richardmrodriguez/fountain-parser-gdext)
  - This is a wrapper for my also-WIP `fountain-parser-rs` ; this simply provides very basic fountain parsing.
- [godot-uuid](https://github.com/binogure-studio/godot-uuid)

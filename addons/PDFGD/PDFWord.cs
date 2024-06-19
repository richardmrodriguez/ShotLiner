using Godot;
using System;
using System.IO;
using System.Collections.Generic;
using System.Linq;


[GlobalClass]
public partial class PDFWord : GodotObject
{
    public Godot.Collections.Array<PDFLetter> PDFLetters = new();

    public Vector2 WordPos = new();
    public Vector2 WordBBox = new();
    // TODO; Implement GetWordBBox which constructs the BBox from the size and pos of its letters

    public string GetWordString()
    {
        string newString = "";
        foreach (PDFLetter letter in PDFLetters)
        {
            newString += letter.Str;

        }
        return newString;
    }

    public Vector2 GetPosition()
    {
        if (PDFLetters.Count == 0)
        {
            GD.Print(" NO LETTERS");
            return new Vector2();
        }
        return PDFLetters[0].Location;
    }

    private Vector2 GetWordBBoxFromLetters()
    {
        // TODO: Implement
        return new Vector2();
    }
}
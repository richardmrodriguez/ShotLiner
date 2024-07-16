using Godot;
using System;
using System.IO;
using System.Collections.Generic;

[GlobalClass]
public partial class PDFLineFN : GodotObject
{
    public Godot.Collections.Array<PDFWord> PDFWords = new();
    public string FNLineType = "";
    public string NominalSceneNum = ""; // Scene num could be 42B for example
    public string LineUUID = "";
    public string NormalizedLine = "";

    public int LineState = 0; //PDFParser.PDF_LINE_STATE enum

    public string GetLineString()
    {
        string newLineString = "";
        Vector2 old_word_bbox = new();
        Vector2 old_word_pos = new();
        foreach (PDFWord word in PDFWords)
        {
            newLineString += word.GetWordString() + " ";
            // FIXME: obviously a naive impelementation that does not account for custom spacing or use of tabs
            // TODO: use the space between words to figure out how many character widths of space 
            // go between them
            // Or, figure out a new strategy to get horizontal lines of text or smth idk
            //GD.Print("Adding to LineString! ", newLineString);
        }

        return newLineString;
    }

    // TODO: ipmlement a func to get the line of text with actual spaces between words,

    public Vector2 GetLinePosition()
    {
        if (PDFWords.Count == 0)
        {
            GD.Print("NO WORDS");
        }


        PDFWord FirstWord = PDFWords[0];

        return FirstWord.GetPosition();

    }


}
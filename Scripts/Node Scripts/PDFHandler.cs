using Godot;
using System;
using System.IO;


// PDFPig 0.1.8
using System.Collections.Generic;
using System.Linq;
using UglyToad.PdfPig;
using UglyToad.PdfPig.Content;
using Godot.NativeInterop;
public partial class PDFHandler : Node
{

	public Godot.GodotObject EventStateManager;

	public string DocFilePath = "";

	public byte[] DocFileBytes;
	// Called when the node enters the scene tree for the first time.
	public override void _Ready()
	{
		//EventStateManager = Engine.GetSingleton("EventStateManager");

	}



	public string GetStringFromPDFPage(string PDFDocPath)
	{


		using (PdfDocument document = PdfDocument.Open(PDFDocPath))
		{
			Page page = document.GetPage(2);

			IEnumerable<Word> words = page.GetWords();
			string test_string = "";
			for (int i = 1; i < 11; i++)
			{
				test_string += words.ElementAt(i) + " ";
			}

			return test_string;
		}
	}


}

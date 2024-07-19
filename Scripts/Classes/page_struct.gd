class_name PageContent

var pdflines: Array[PDFLineFN] # TODO: Refactor page construction to add PDFLineFNs instead of FNLineGDs
var page_size: Vector2 = Vector2(72 * 8.5, 72 * 11)
var dpi: float = 72.0

func get_pagecontent_as_dict() -> Dictionary:
    assert(false, "NOT YET FIXED")
    return {
        "lines": pdflines.map(
            func(line: PDFLineFN) -> Dictionary:
                return {
                    "string": line.string,
                    "pos": line.pos,
                    "uuid": line.get_uuid()
                }
                )
    }
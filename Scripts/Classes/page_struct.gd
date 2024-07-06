class_name PageContent

var lines: Array[FNLineGD]
var pdflines: Array[PDFLineFN] # TODO: Refactor page construction to add PDFLineFNs instead of FNLineGDs
var page_size: Vector2 = Vector2(72 * 8.5, 72 * 11)
var dpi: float = 72.0

func get_pagecontent_as_dict() -> Dictionary:
    return {
        "lines": lines.map(
            func(line: FNLineGD) -> Dictionary:
                return {
                    "string": line.string,
                    "fn_type": line.fn_type,
                    "is_type_forced": line.is_type_forced,
                    "pos": line.pos,
                    "uuid": line.uuid
                }
                )
    }
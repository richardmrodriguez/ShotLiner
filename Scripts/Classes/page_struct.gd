class_name PageContent

var lines: Array[FNLineGD]

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
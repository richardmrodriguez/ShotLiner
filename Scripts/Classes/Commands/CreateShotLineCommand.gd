extends Command

class_name CreateShotLineCommand

var shotline_obj: Shotline
var shotline_uuid: String
var this_shotline_2D: ShotLine2DContainer
var page_panel: Node

func execute() -> bool:
    if params:
        shotline_obj = params.front()
        page_panel = params.back()
        shotline_uuid = shotline_obj.shotline_uuid
        # two steps:
        # 1. Add shotline object to shotlines array
        # 2. Add Shotline container to current page
        # to undo:
        # 1. get shotline container by uuid, queue free
        # 2. remove shotline obj from array by uuid

        ScreenplayDocument.shotlines.append(shotline_obj)
        
        this_shotline_2D = shotline_obj.shotline_2D_scene.instantiate()
        this_shotline_2D.construct_shotline_node(shotline_obj)
        page_panel.add_child(this_shotline_2D)
        shotline_obj.shotline_node = this_shotline_2D
        return true
    return false
    
func undo() -> bool:

    if ScreenplayDocument.shotlines.has(shotline_obj):
        print("removing shotline node...")

        for child: Node in page_panel.get_children():
            if not child is ShotLine2DContainer:
                continue
            if child.shotline_struct_reference.shotline_uuid == shotline_uuid:
                page_panel.remove_child(child)
                child.queue_free()
        ScreenplayDocument.shotlines.erase(shotline_obj)

        return true
    return false
    #this_shotline_2D.queue_free()
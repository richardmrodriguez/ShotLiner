## This class is responsible for taking the PDFLineFN inputs from a PDFDocGD 
## and returning a list of `ScreenplayPageContent`s which have been properly modified and marked
## I.E. Each line belongs to a scene, each line has an FNlineType, etc.
class_name PDFScreenplayParser

# TODO: Replace the FNLineGD obj which is declared in the rust wrapper with a GDScript obj

## This class is responsible for taking the PDFLineFN inputs from a PDFDocGD 
## and returning a list of `ScreenplayPageContent`s which have been properly modified and marked
## I.E. Each line belongs to a scene, each line has an FNlineType, etc.
#class_name PDFScreenplayParser
extends Node

enum PDF_LINE_STATE {
    WITHIN_BODY_MARGINS,
    BEFORE_LEFT_MARGIN,
    AFTER_RIGHT_MARGIN,
    BEFORE_LEFT_AND_AFTER_RIGHT_MARGIN,
    ABOVE_TOP_MARGIN,
    BELOW_BOTTOM_MARGIN,
}

var left_margin_in: float = 1.5
var right_margin_in: float = 1
var top_margin_in: float = 1
var bottom_margin_in: float = 1

# TODO: Special Case Parsing for Production Script elements:

    # For each of these Elements, simply strip out any extraneous text, assign the appropriate
    # values to the FNLineGD, then send this FNlineGD off to be "really" parsed by the main parser.
        # Sluglines with Scene Numbers 
            # The scene numbers bookend at a fixed position before and after the body margins
        # Revised lines { * Text'content..... *}
            # The Revision asterisk `*` bookend at a fixed position before and after the body margins
        # Page Numbers
            # Fixed position above body margins, first page of a screenplay usually doesn't have a page number printed
        # Headers / Footers (likely revision dates)
            # Above / Below body margins
        # Omitted Scenes
            # This is just text that says "OMITTED", but is also marked as "omitted" in its FNlineGD
            # This is important for diffing between revisions of documents

#

## Returns false if line's x position is outside the "body" area
func get_PDFLine_body_state(
    line: PDFLineFN,
    pdf_page_size_points: Vector2,
    letter_point_size: float,
    letter_width: float,
    ) -> PDF_LINE_STATE:

    var is_before_left_margin: bool = false
    var is_after_right_margin: bool = false
    var is_above_top_margin: bool = false
    var is_below_bottom_margin: bool = false

    var dpi: float = 72.0
    var page_type: String = "A4"
    if (pdf_page_size_points.x / pdf_page_size_points.y) > 0.709:
        page_type = "USLETTER"

    if page_type == "USLETTER":
        dpi = pdf_page_size_points.x / 8.5
    else:
        dpi = pdf_page_size_points.x / 8.3

    var page_size_in_letters: Vector2 = Vector2(
        pdf_page_size_points.x / letter_width,
        pdf_page_size_points.y / letter_point_size
    )
    #----------Left Margin Check
    var first_word: PDFWord = line.PDFWords[0]
    var first_letter: PDFLetter = first_word.PDFLetters[0]
    if first_letter.Location.x < dpi * left_margin_in: # less than 1 inch from left hand side
        is_before_left_margin = true
    #---------Right Margin Check
    var last_word: PDFWord = line.PDFWords[- 1]
    var last_letter: PDFLetter = last_word.PDFLetters[- 1]
    if (pdf_page_size_points.x - last_letter.Location.x) < dpi * right_margin_in:
        is_after_right_margin = true
    #--------Top Margin Check
    if (pdf_page_size_points.y - first_letter.Location.y) < dpi * top_margin_in: # less than 1 inch rom top edge of page
        is_above_top_margin = true
    #--------Bottom Margin Check
    if first_letter.Location.y < dpi * bottom_margin_in:
        is_below_bottom_margin = true

    if not (
        is_above_top_margin or
        is_below_bottom_margin or
        is_before_left_margin or
        is_after_right_margin):
        return PDF_LINE_STATE.WITHIN_BODY_MARGINS

    if is_above_top_margin:
        return PDF_LINE_STATE.ABOVE_TOP_MARGIN
    elif is_below_bottom_margin:
        return PDF_LINE_STATE.BELOW_BOTTOM_MARGIN

    if is_before_left_margin and is_after_right_margin:
        return PDF_LINE_STATE.BEFORE_LEFT_AND_AFTER_RIGHT_MARGIN
    elif is_before_left_margin:
        return PDF_LINE_STATE.BEFORE_LEFT_MARGIN
    elif is_after_right_margin:
        return PDF_LINE_STATE.AFTER_RIGHT_MARGIN

    return PDF_LINE_STATE.WITHIN_BODY_MARGINS

func get_PDF_font_size_mode_as_int() -> int:
    return 0
    
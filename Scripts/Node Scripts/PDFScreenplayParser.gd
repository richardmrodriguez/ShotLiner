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

@export var left_margin_in: float = 1.5
@export var right_margin_in: float = 1
@export var top_margin_in: float = 1
@export var bottom_margin_in: float = 1

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

## Returns the state of a PDFLine, if it is within the body margins,
## or if it is above or below the top and bottom, 
## or if it is before or after (or both before and after) the left and right-hand margins. 
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

    var dpi: float = get_dpi_from_pagesize(pdf_page_size_points)

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

func get_dpi_from_pagesize(pagesize: Vector2) -> float:
    var dpi: float = 72.0
    var page_type: String = "A4"
    if (pagesize.x / pagesize.y) > 0.709:
        page_type = "USLETTER"

    if page_type == "USLETTER":
        dpi = pagesize.x / 8.5
    else:
        dpi = pagesize.x / 8.3
    
    return dpi

## Get normalized body text, without line numbers or revision asterisks

func get_normalized_body_text(
    pdfline: PDFLineFN,
    pdf_page_size_points: Vector2,
    letter_point_size: float,
    letter_width: float, ) -> String:

    var normalized_text: String = ""
    var dpi: float = get_dpi_from_pagesize(pdf_page_size_points)
    match get_PDFLine_body_state(
        pdfline,
        pdf_page_size_points,
        letter_point_size,
        letter_width):
        PDF_LINE_STATE.BEFORE_LEFT_MARGIN, PDF_LINE_STATE.AFTER_RIGHT_MARGIN, PDF_LINE_STATE.BEFORE_LEFT_AND_AFTER_RIGHT_MARGIN:
            var last_pdf_word: PDFWord = null
            for cur_word: PDFWord in pdfline.PDFWords:
                var first_letter_pos: float = cur_word.PDFLetters[0].Location.x
                if (first_letter_pos < dpi * left_margin_in) or ((pdf_page_size_points.x - first_letter_pos) < dpi * right_margin_in
                ):
                    continue
                else:
                    normalized_text += get_spaces_between_character_positions(
                        cur_word,
                        last_pdf_word,
                        dpi)
                    if not last_pdf_word:
                        last_pdf_word = cur_word
                        
                        #assert(false, normalized_text)
                        
                    normalized_text += cur_word.GetWordString()
                    last_pdf_word = cur_word
    
    return normalized_text

func get_spaces_between_character_positions(new_word: PDFWord, old_word: PDFWord, dpi: float) -> String:
    if not old_word:
        return ""
    var new_x: float = new_word.PDFLetters[0].Location.x
    var old_x: float = old_word.PDFLetters[- 1].Location.x
    var char_width: float = dpi * 0.1
    var spaces: int = int(abs(new_x - old_x) / char_width)
        
    return " ".repeat(spaces)
    
import gleam/bit_array
import gleam/float
import gleam/int
import gleam/list
import gleam/option.{None, Some}
import gleam/string
import gleam/time/calendar
import gleam/time/timestamp

/// A PDF document.
///
pub opaque type Document {
  Document(
    info: Info,
    pages: List(Page),
    default_font: String,
    default_text_size: Float,
    default_text_colour: Colour,
    default_page_size: PageSize,
  )
}

/// A single page in a PDF document.
///
pub opaque type Page {
  Page(size: option.Option(PageSize), contents: List(Content))
}

/// Dimensions of a page in points, where one point is 0.353mm.
///
pub type PageSize {
  PageSize(width: Float, height: Float)
}

pub const size_a3 = PageSize(width: 842.0, height: 1191.0)

pub const size_a4 = PageSize(width: 595.0, height: 842.0)

pub const size_a5 = PageSize(width: 420.0, height: 595.0)

pub const size_usa_letter = PageSize(width: 612.0, height: 792.0)

pub const size_usa_legal = PageSize(width: 612.0, height: 1008.0)

/// Convert a page size to portrait orientation.
///
/// The smaller dimension becomes the width.
///
pub fn portrait(size: PageSize) -> PageSize {
  case size.width <=. size.height {
    True -> size
    False -> PageSize(width: size.height, height: size.width)
  }
}

/// Convert a page size to landscape orientation.
///
/// The larger dimension becomes the width.
///
pub fn landscape(size: PageSize) -> PageSize {
  case size.width >=. size.height {
    True -> size
    False -> PageSize(width: size.height, height: size.width)
  }
}

/// A colour for use in PDF content.
///
pub type Colour {
  /// An RGB colour with red, green, and blue components from 0.0 to 1.0.
  ///
  Rgb(red: Float, green: Float, blue: Float)
}

/// A piece of text to be drawn on a page.
///
pub opaque type Text {
  Text(
    content: String,
    x: Float,
    y: Float,
    font: option.Option(String),
    size: option.Option(Float),
    colour: option.Option(Colour),
  )
}

/// A rectangle to be drawn on a page.
///
pub opaque type Rectangle {
  Rectangle(
    x: Float,
    y: Float,
    width: Float,
    height: Float,
    fill_colour: option.Option(Colour),
    stroke_colour: option.Option(Colour),
    line_width: option.Option(Float),
  )
}

/// An open path made up of lines.
///
pub opaque type Path {
  Path(
    start_x: Float,
    start_y: Float,
    operations: List(PathOperation),
    stroke_colour: option.Option(Colour),
    line_width: option.Option(Float),
  )
}

/// A closed shape made from one or more paths.
///
pub opaque type Shape {
  Shape(
    subpaths: List(Subpath),
    fill_colour: option.Option(Colour),
    stroke_colour: option.Option(Colour),
    line_width: option.Option(Float),
  )
}

type Subpath {
  Subpath(start_x: Float, start_y: Float, operations: List(PathOperation))
}

type PathOperation {
  LineTo(x: Float, y: Float)
}

type Content {
  ContentText(Text)
  ContentRectangle(Rectangle)
  ContentPath(Path)
  ContentShape(Shape)
}

type Info {
  Info(
    title: option.Option(String),
    author: option.Option(String),
    subject: option.Option(String),
    keywords: option.Option(String),
    creator: option.Option(String),
    producer: option.Option(String),
    creation_time: option.Option(timestamp.Timestamp),
    modification_time: option.Option(timestamp.Timestamp),
  )
}

/// Create a new blank page.
///
pub fn new_page() -> Page {
  Page(size: None, contents: [])
}

/// Set the size of a page.
///
pub fn page_size(page: Page, size: PageSize) -> Page {
  Page(..page, size: Some(size))
}

/// Create a new document.
///
pub fn new_document() -> Document {
  Document(
    info: Info(
      title: None,
      author: None,
      subject: None,
      keywords: None,
      creator: None,
      producer: None,
      creation_time: None,
      modification_time: None,
    ),
    pages: [],
    default_font: "Helvetica",
    default_text_size: 12.0,
    default_text_colour: Rgb(0.0, 0.0, 0.0),
    default_page_size: size_a4,
  )
}

/// Set the title of the document.
///
pub fn title(document: Document, title: String) -> Document {
  Document(..document, info: Info(..document.info, title: Some(title)))
}

/// Set the name of the person who created the document content.
///
pub fn author(document: Document, author: String) -> Document {
  Document(..document, info: Info(..document.info, author: Some(author)))
}

/// Set the subject of the document.
///
pub fn subject(document: Document, subject: String) -> Document {
  Document(..document, info: Info(..document.info, subject: Some(subject)))
}

/// Set keywords associated with the document, typically comma-separated.
///
pub fn keywords(document: Document, keywords: String) -> Document {
  Document(..document, info: Info(..document.info, keywords: Some(keywords)))
}

/// Set the name of the application that created the original content.
///
pub fn creator(document: Document, creator: String) -> Document {
  Document(..document, info: Info(..document.info, creator: Some(creator)))
}

/// Set the name of the application that produced the PDF.
///
pub fn producer(document: Document, producer: String) -> Document {
  Document(..document, info: Info(..document.info, producer: Some(producer)))
}

/// Set the date and time when the document was created.
///
pub fn created_at(document: Document, time: timestamp.Timestamp) -> Document {
  Document(..document, info: Info(..document.info, creation_time: Some(time)))
}

/// Set the date and time when the document was last modified.
///
pub fn modified_at(document: Document, time: timestamp.Timestamp) -> Document {
  Document(
    ..document,
    info: Info(..document.info, modification_time: Some(time)),
  )
}

/// Set the default font for text in the document.
///
/// This font is used when text is added without specifying a font.
///
pub fn default_font(document: Document, font: String) -> Document {
  Document(..document, default_font: font)
}

/// Set the default text size for the document in points.
///
/// This size is used when text is added without specifying a size.
///
pub fn default_text_size(document: Document, size: Float) -> Document {
  Document(..document, default_text_size: size)
}

/// Set the default text colour for the document.
///
/// This colour is used when text is added without specifying a colour.
///
pub fn default_text_colour(document: Document, colour: Colour) -> Document {
  Document(..document, default_text_colour: colour)
}

/// Set the default page size for the document.
///
pub fn default_page_size(document: Document, size: PageSize) -> Document {
  Document(..document, default_page_size: size)
}

/// Append a page to the document.
///
/// ## Examples
///
/// ```gleam
/// new_document()
/// |> add_page(new_page())
/// ```
///
pub fn add_page(document: Document, page: Page) -> Document {
  Document(..document, pages: list.append(document.pages, [page]))
}

/// Create a new text element at the given position.
///
/// The position is specified in points from the bottom-left corner of the page.
///
/// ## Examples
///
/// ```gleam
/// text("Hello, world!", x: 72.0, y: 750.0)
/// |> font("Times-Roman")
/// |> text_size(14.0)
/// ```
///
pub fn text(content: String, x x: Float, y y: Float) -> Text {
  Text(content:, x:, y:, font: None, size: None, colour: None)
}

/// Set the font for a text element.
///
/// The font must be the name of one of the 14 standard PDF fonts, such as
/// `"Helvetica"` or `"Times-Roman"`.
///
pub fn font(text: Text, font: String) -> Text {
  Text(..text, font: Some(font))
}

/// Set the size for a text element in points.
///
pub fn text_size(text: Text, size: Float) -> Text {
  Text(..text, size: Some(size))
}

/// Set the colour for a text element.
///
pub fn text_colour(text: Text, colour: Colour) -> Text {
  Text(..text, colour: Some(colour))
}

/// Add a text element to the page.
///
/// ## Examples
///
/// ```gleam
/// new_page()
/// |> add_text(text("Hello, world!", x: 72.0, y: 750.0))
/// ```
///
pub fn add_text(page: Page, text: Text) -> Page {
  Page(..page, contents: list.append(page.contents, [ContentText(text)]))
}

/// Create a new rectangle at the given position with the given dimensions.
///
/// The position is specified in points from the bottom-left corner of the page.
/// The rectangle will be invisible until a fill or stroke colour is set.
///
pub fn rectangle(
  x x: Float,
  y y: Float,
  width width: Float,
  height height: Float,
) -> Rectangle {
  Rectangle(
    x:,
    y:,
    width:,
    height:,
    fill_colour: None,
    stroke_colour: None,
    line_width: None,
  )
}

/// Set the fill colour for a rectangle.
///
pub fn rectangle_fill_colour(rectangle: Rectangle, colour: Colour) -> Rectangle {
  Rectangle(..rectangle, fill_colour: Some(colour))
}

/// Set the stroke colour for a rectangle.
///
pub fn rectangle_stroke_colour(
  rectangle: Rectangle,
  colour: Colour,
) -> Rectangle {
  Rectangle(..rectangle, stroke_colour: Some(colour))
}

/// Set the line width for a rectangle's stroke in points.
///
pub fn rectangle_line_width(rectangle: Rectangle, width: Float) -> Rectangle {
  Rectangle(..rectangle, line_width: Some(width))
}

/// Add a rectangle to the page.
///
pub fn add_rectangle(page: Page, rectangle: Rectangle) -> Page {
  Page(
    ..page,
    contents: list.append(page.contents, [ContentRectangle(rectangle)]),
  )
}

/// Create a new path starting at the given point.
///
pub fn path(x x: Float, y y: Float) -> Path {
  Path(
    start_x: x,
    start_y: y,
    operations: [],
    stroke_colour: None,
    line_width: None,
  )
}

/// Add a line to the path.
///
pub fn line(path: Path, x x: Float, y y: Float) -> Path {
  Path(..path, operations: list.append(path.operations, [LineTo(x, y)]))
}

/// Set the stroke colour for a path.
///
pub fn path_stroke_colour(path: Path, colour: Colour) -> Path {
  Path(..path, stroke_colour: Some(colour))
}

/// Set the line width for a path in points.
///
pub fn path_line_width(path: Path, width: Float) -> Path {
  Path(..path, line_width: Some(width))
}

/// Add a path to the page.
///
pub fn add_path(page: Page, path: Path) -> Page {
  Page(..page, contents: list.append(page.contents, [ContentPath(path)]))
}

/// Close a path to create a shape.
///
/// The path's stroke colour and line width are not inherited. Use
/// `shape_stroke_colour` and `shape_line_width` to set them on the shape.
///
pub fn shape(path: Path) -> Shape {
  let subpath = Subpath(path.start_x, path.start_y, path.operations)
  Shape(
    subpaths: [subpath],
    fill_colour: None,
    stroke_colour: None,
    line_width: None,
  )
}

/// Create a compound shape from multiple paths.
///
/// The paths' stroke colours and line widths are not inherited. Use
/// `shape_stroke_colour` and `shape_line_width` to set them on the shape.
///
pub fn compound_shape(paths: List(Path)) -> Shape {
  let subpaths =
    list.map(paths, fn(p) { Subpath(p.start_x, p.start_y, p.operations) })
  Shape(subpaths:, fill_colour: None, stroke_colour: None, line_width: None)
}

/// Set the fill colour for a shape.
///
pub fn shape_fill_colour(shape: Shape, colour: Colour) -> Shape {
  Shape(..shape, fill_colour: Some(colour))
}

/// Set the stroke colour for a shape.
///
pub fn shape_stroke_colour(shape: Shape, colour: Colour) -> Shape {
  Shape(..shape, stroke_colour: Some(colour))
}

/// Set the line width for a shape in points.
///
pub fn shape_line_width(shape: Shape, width: Float) -> Shape {
  Shape(..shape, line_width: Some(width))
}

/// Add a shape to the page.
///
pub fn add_shape(page: Page, shape: Shape) -> Page {
  Page(..page, contents: list.append(page.contents, [ContentShape(shape)]))
}

type Object {
  Object(
    id: Int,
    stream: option.Option(BitArray),
    dictionary: List(#(String, Value)),
  )
}

type Value {
  Reference(reference: Int)
  Name(name: String)
  String(value: String)
  Float(value: Float)
  Int(value: Int)
  Bool(value: Bool)
  Null
  Array(elements: List(Value))
  Dictionary(values: List(#(String, Value)))
}

/// Render the document to a PDF file as a bit array.
///
/// The resulting bytes can be written directly to a file.
///
/// ## Examples
///
/// ```gleam
/// new_document()
/// |> title("My Document")
/// |> add_page(
///   new_page()
///   |> add_text(text("Hello!", x: 72.0, y: 750.0)),
/// )
/// |> render
/// ```
///
pub fn render(document: Document) -> BitArray {
  document
  |> document_to_objects
  |> render_pdf(document.info)
}

fn document_to_objects(document: Document) -> List(Object) {
  let page_count = list.length(document.pages)
  let page_ids = list.range(3, 3 + page_count - 1)
  let page_refs = list.map(page_ids, Reference)

  let catalog =
    Object(1, None, [#("Type", Name("Catalog")), #("Pages", Reference(2))])

  let pages =
    Object(2, None, [
      #("Type", Name("Pages")),
      #("Kids", Array(page_refs)),
      #("Count", Int(page_count)),
    ])

  let #(page_objects, _) =
    list.fold(
      list.zip(document.pages, page_ids),
      #([], 3 + page_count),
      fn(acc, pair) {
        let #(objects, next_id) = acc
        let #(page, page_id) = pair
        let #(page_obj, content_obj, font_objs, next_id) =
          page_to_objects(page, page_id, next_id, document)
        #(list.flatten([objects, [page_obj, content_obj], font_objs]), next_id)
      },
    )

  [catalog, pages, ..page_objects]
}

fn page_to_objects(
  page: Page,
  page_id: Int,
  next_id: Int,
  document: Document,
) -> #(Object, Object, List(Object), Int) {
  let content_id = next_id
  let fonts = collect_fonts(page.contents, document.default_font)
  let font_start_id = next_id + 1
  let size = option.unwrap(page.size, document.default_page_size)

  let #(font_dict, font_objs, next_id) =
    list.fold(
      list.index_map(fonts, fn(font, i) { #(font, i) }),
      #([], [], font_start_id),
      fn(acc, pair) {
        let #(dict, objs, obj_id) = acc
        let #(font, index) = pair
        let font_key = "F" <> int.to_string(index + 1)
        let font_obj =
          Object(obj_id, None, [
            #("Type", Name("Font")),
            #("Subtype", Name("Type1")),
            #("BaseFont", Name(font)),
          ])
        #(
          [#(font_key, Reference(obj_id)), ..dict],
          [font_obj, ..objs],
          obj_id + 1,
        )
      },
    )

  let content_stream = render_content_stream(page.contents, document)

  let page_obj =
    Object(page_id, None, [
      #("Type", Name("Page")),
      #("Parent", Reference(2)),
      #(
        "MediaBox",
        Array([Int(0), Int(0), Float(size.width), Float(size.height)]),
      ),
      #("Resources", Dictionary([#("Font", Dictionary(font_dict))])),
      #("Contents", Reference(content_id)),
    ])

  let content_obj = Object(content_id, Some(content_stream), [])

  #(page_obj, content_obj, list.reverse(font_objs), next_id)
}

fn collect_fonts(contents: List(Content), default_font: String) -> List(String) {
  list.fold(contents, [], fn(fonts, content) {
    case content {
      ContentText(Text(font:, ..)) -> {
        let font = option.unwrap(font, default_font)
        case list.contains(fonts, font) {
          True -> fonts
          False -> [font, ..fonts]
        }
      }
      ContentRectangle(_) -> fonts
      ContentPath(_) -> fonts
      ContentShape(_) -> fonts
    }
  })
  |> list.reverse
}

fn render_content_stream(
  contents: List(Content),
  document: Document,
) -> BitArray {
  let fonts = collect_fonts(contents, document.default_font)
  list.fold(contents, <<>>, fn(stream, content) {
    case content {
      ContentText(text) -> render_text(stream, text, fonts, document)
      ContentRectangle(rect) -> render_rectangle(stream, rect)
      ContentPath(path) -> render_path(stream, path)
      ContentShape(shape) -> render_shape(stream, shape)
    }
  })
}

fn render_text(
  stream: BitArray,
  text: Text,
  fonts: List(String),
  document: Document,
) -> BitArray {
  let Text(content:, x:, y:, font:, size:, colour:) = text
  let font = option.unwrap(font, document.default_font)
  let size = option.unwrap(size, document.default_text_size)
  let colour = option.unwrap(colour, document.default_text_colour)
  let font_index = case
    list.index_map(fonts, fn(f, i) { #(f, i) })
    |> list.find(fn(p) { p.0 == font })
  {
    Ok(#(_, i)) -> i
    Error(_) -> 0
  }
  let font_key = "/F" <> int.to_string(font_index + 1)
  let stream = <<stream:bits, "BT\n">>
  let stream = <<
    stream:bits,
    render_float(colour.red):utf8,
    " ",
    render_float(colour.green):utf8,
    " ",
    render_float(colour.blue):utf8,
    " rg\n",
  >>
  let encoded_content = utf8_to_win_ansi(content)
  <<
    stream:bits,
    font_key:utf8,
    " ",
    render_float(size):utf8,
    " Tf\n1 0 0 1 ",
    render_float(x):utf8,
    " ",
    render_float(y):utf8,
    " Tm\n(",
    encoded_content:bits,
    ") Tj\nET\n",
  >>
}

fn render_rectangle(stream: BitArray, rect: Rectangle) -> BitArray {
  let Rectangle(
    x:,
    y:,
    width:,
    height:,
    fill_colour:,
    stroke_colour:,
    line_width:,
  ) = rect

  // Set line width if specified
  let stream = case line_width {
    Some(w) -> <<stream:bits, render_float(w):utf8, " w\n">>
    None -> stream
  }

  // Set fill colour if specified
  let stream = case fill_colour {
    Some(Rgb(r, g, b)) -> <<
      stream:bits,
      render_float(r):utf8,
      " ",
      render_float(g):utf8,
      " ",
      render_float(b):utf8,
      " rg\n",
    >>
    None -> stream
  }

  // Set stroke colour if specified
  let stream = case stroke_colour {
    Some(Rgb(r, g, b)) -> <<
      stream:bits,
      render_float(r):utf8,
      " ",
      render_float(g):utf8,
      " ",
      render_float(b):utf8,
      " RG\n",
    >>
    None -> stream
  }

  // Draw the rectangle path
  let stream = <<
    stream:bits,
    render_float(x):utf8,
    " ",
    render_float(y):utf8,
    " ",
    render_float(width):utf8,
    " ",
    render_float(height):utf8,
    " re\n",
  >>

  // Fill and/or stroke
  case fill_colour, stroke_colour {
    Some(_), Some(_) -> <<stream:bits, "B\n">>
    Some(_), None -> <<stream:bits, "f\n">>
    None, Some(_) -> <<stream:bits, "S\n">>
    None, None -> stream
  }
}

fn render_path(stream: BitArray, path: Path) -> BitArray {
  let Path(start_x:, start_y:, operations:, stroke_colour:, line_width:) = path

  // Set line width if specified
  let stream = case line_width {
    Some(w) -> <<stream:bits, render_float(w):utf8, " w\n">>
    None -> stream
  }

  // Set stroke colour if specified
  let stream = case stroke_colour {
    Some(Rgb(r, g, b)) -> <<
      stream:bits,
      render_float(r):utf8,
      " ",
      render_float(g):utf8,
      " ",
      render_float(b):utf8,
      " RG\n",
    >>
    None -> stream
  }

  // Move to start
  let stream = <<
    stream:bits,
    render_float(start_x):utf8,
    " ",
    render_float(start_y):utf8,
    " m\n",
  >>

  // Draw lines
  let stream =
    list.fold(operations, stream, fn(stream, op) {
      case op {
        LineTo(x, y) -> <<
          stream:bits,
          render_float(x):utf8,
          " ",
          render_float(y):utf8,
          " l\n",
        >>
      }
    })

  // Stroke the path
  <<stream:bits, "S\n">>
}

fn render_shape(stream: BitArray, shape: Shape) -> BitArray {
  let Shape(subpaths:, fill_colour:, stroke_colour:, line_width:) = shape

  // Set line width if specified
  let stream = case line_width {
    Some(w) -> <<stream:bits, render_float(w):utf8, " w\n">>
    None -> stream
  }

  // Set fill colour if specified
  let stream = case fill_colour {
    Some(Rgb(r, g, b)) -> <<
      stream:bits,
      render_float(r):utf8,
      " ",
      render_float(g):utf8,
      " ",
      render_float(b):utf8,
      " rg\n",
    >>
    None -> stream
  }

  // Set stroke colour if specified
  let stream = case stroke_colour {
    Some(Rgb(r, g, b)) -> <<
      stream:bits,
      render_float(r):utf8,
      " ",
      render_float(g):utf8,
      " ",
      render_float(b):utf8,
      " RG\n",
    >>
    None -> stream
  }

  // Draw each subpath
  let stream =
    list.fold(subpaths, stream, fn(stream, subpath) {
      let Subpath(start_x, start_y, operations) = subpath

      // Move to start
      let stream = <<
        stream:bits,
        render_float(start_x):utf8,
        " ",
        render_float(start_y):utf8,
        " m\n",
      >>

      // Draw lines
      let stream =
        list.fold(operations, stream, fn(stream, op) {
          case op {
            LineTo(x, y) -> <<
              stream:bits,
              render_float(x):utf8,
              " ",
              render_float(y):utf8,
              " l\n",
            >>
          }
        })

      // Close subpath
      <<stream:bits, "h\n">>
    })

  // Fill and/or stroke (using even-odd rule for fill)
  case fill_colour, stroke_colour {
    Some(_), Some(_) -> <<stream:bits, "B*\n">>
    Some(_), None -> <<stream:bits, "f*\n">>
    None, Some(_) -> <<stream:bits, "S\n">>
    None, None -> stream
  }
}

fn render_pdf(objects: List(Object), info: Info) -> BitArray {
  let pdf = <<"%PDF-1.4\n">>
  let info_id = list.length(objects) + 1
  let #(pdf, offsets) = render_objects(pdf, objects, [])
  let info_object = render_info_object(info_id, info)
  let #(pdf, offsets) = render_object(pdf, info_object, offsets)
  let offsets = list.reverse(offsets)
  let xref_start = bit_array.byte_size(pdf)
  let pdf = render_xref(pdf, offsets)
  let pdf = render_trailer(pdf, info_id, xref_start, info_id)
  pdf
}

fn render_objects(
  pdf: BitArray,
  objects: List(Object),
  offsets: List(Int),
) -> #(BitArray, List(Int)) {
  case objects {
    [] -> #(pdf, offsets)
    [object, ..objects] -> {
      let #(pdf, offsets) = render_object(pdf, object, offsets)
      render_objects(pdf, objects, offsets)
    }
  }
}

fn render_object(
  pdf: BitArray,
  object: Object,
  offsets: List(Int),
) -> #(BitArray, List(Int)) {
  let Object(id:, stream:, dictionary:) = object
  let offsets = [bit_array.byte_size(pdf), ..offsets]
  let pdf = <<pdf:bits, int.to_string(id):utf8, " 0 obj\n">>

  let dictionary = case stream {
    None -> dictionary
    Some(stream) -> {
      [#("Length", Int(bit_array.byte_size(stream))), ..dictionary]
    }
  }

  let pdf = render_dictionary(pdf, dictionary)
  let pdf = <<pdf:bits, "\n">>

  let pdf = case stream {
    Some(bits) -> <<
      pdf:bits,
      "stream\n",
      bits:bits,
      "\nendstream\n",
    >>
    None -> pdf
  }

  let pdf = <<pdf:bits, "endobj\n">>
  #(pdf, offsets)
}

fn render_dictionary(
  pdf: BitArray,
  dictionary: List(#(String, Value)),
) -> BitArray {
  let pdf = <<pdf:bits, "<<">>
  let pdf =
    list.fold(dictionary, pdf, fn(pdf, property) {
      let pdf = <<pdf:bits, "/", property.0:utf8, " ">>
      let pdf = render_value(pdf, property.1)
      <<pdf:bits, "\n">>
    })
  let pdf = <<pdf:bits, ">>">>
  pdf
}

fn render_array(pdf: BitArray, array: List(Value)) -> BitArray {
  let pdf = <<pdf:bits, "[">>
  let pdf =
    list.fold(array, pdf, fn(pdf, value) {
      <<render_value(pdf, value):bits, " ">>
    })
  let pdf = <<pdf:bits, "]">>
  pdf
}

fn render_value(pdf: BitArray, value: Value) -> BitArray {
  case value {
    Reference(r) -> <<pdf:bits, int.to_string(r):utf8, " 0 R">>
    Name(n) -> <<pdf:bits, "/", n:utf8>>
    String(s) -> <<pdf:bits, "(", s:utf8, ")">>
    Float(f) -> <<pdf:bits, render_float(f):utf8>>
    Int(f) -> <<pdf:bits, int.to_string(f):utf8>>
    Bool(True) -> <<pdf:bits, "true">>
    Bool(False) -> <<pdf:bits, "false">>
    Null -> <<pdf:bits, "null">>
    Array(array) -> render_array(pdf, array)
    Dictionary(pairs) -> render_dictionary(pdf, pairs)
  }
}

fn render_float(f: Float) -> String {
  let truncated = float.truncate(f)
  case int.to_float(truncated) == f {
    True -> int.to_string(truncated)
    False -> float.to_string(f)
  }
}

/// Convert UTF-8 text to WinAnsiEncoding for PDF standard fonts.
///
/// PDF's 14 standard fonts (Helvetica, Times-Roman, Courier, Symbol, and
/// ZapfDingbats families) use WinAnsiEncoding, which is based on Windows-1252.
/// This encoding supports ASCII, Latin-1 Supplement (accented characters for
/// Western European languages), and some additional characters like curly
/// quotes, em-dashes, and the Euro sign.
///
/// Characters outside this encoding (such as Cyrillic, Greek, Chinese, etc.)
/// are replaced with "?". To display these characters, you would need to embed
/// a TrueType or OpenType font that supports them, which is not yet implemented.
///
fn utf8_to_win_ansi(text: String) -> BitArray {
  text
  |> string.to_utf_codepoints
  |> list.map(codepoint_to_win_ansi)
  |> bit_array.concat
}

fn codepoint_to_win_ansi(codepoint: UtfCodepoint) -> BitArray {
  let code = string.utf_codepoint_to_int(codepoint)
  case code {
    // ASCII range - same in both encodings
    c if c >= 0 && c <= 127 -> <<c>>
    // Latin-1 Supplement (U+00A0 to U+00FF) - maps directly
    c if c >= 160 && c <= 255 -> <<c>>
    // Special WinAnsi mappings for characters outside Latin-1
    // €
    0x20AC -> <<0x80>>
    // ‚
    0x201A -> <<0x82>>
    // ƒ
    0x0192 -> <<0x83>>
    // „
    0x201E -> <<0x84>>
    // …
    0x2026 -> <<0x85>>
    // †
    0x2020 -> <<0x86>>
    // ‡
    0x2021 -> <<0x87>>
    // ˆ
    0x02C6 -> <<0x88>>
    // ‰
    0x2030 -> <<0x89>>
    // Š
    0x0160 -> <<0x8A>>
    // ‹
    0x2039 -> <<0x8B>>
    // Œ
    0x0152 -> <<0x8C>>
    // Ž
    0x017D -> <<0x8E>>
    // '
    0x2018 -> <<0x91>>
    // '
    0x2019 -> <<0x92>>
    // "
    0x201C -> <<0x93>>
    // "
    0x201D -> <<0x94>>
    // •
    0x2022 -> <<0x95>>
    // –
    0x2013 -> <<0x96>>
    // —
    0x2014 -> <<0x97>>
    // ˜
    0x02DC -> <<0x98>>
    // ™
    0x2122 -> <<0x99>>
    // š
    0x0161 -> <<0x9A>>
    // ›
    0x203A -> <<0x9B>>
    // œ
    0x0153 -> <<0x9C>>
    // ž
    0x017E -> <<0x9E>>
    // Ÿ
    0x0178 -> <<0x9F>>
    // Fallback: use ? for unsupported characters
    _ -> <<"?">>
  }
}

fn render_xref(pdf: BitArray, offsets: List(Int)) -> BitArray {
  let count = list.length(offsets)
  let pdf = <<
    pdf:bits,
    "xref\n0 ",
    int.to_string(count + 1):utf8,
    "\n",
    "0000000000 65535 f \n",
  >>

  list.fold(offsets, pdf, fn(pdf, offset) {
    let offset = string.pad_start(int.to_string(offset), 10, "0")
    <<pdf:bits, offset:utf8, " 00000 n \n">>
  })
}

fn render_trailer(
  pdf: BitArray,
  count: Int,
  xref_start: Int,
  info_id: Int,
) -> BitArray {
  <<
    pdf:bits,
    "trailer\n",
    "<<\n",
    "/Size ",
    int.to_string(count + 1):utf8,
    "\n",
    "/Root 1 0 R\n",
    "/Info ",
    int.to_string(info_id):utf8,
    " 0 R\n",
    ">>\n",
    "startxref\n",
    int.to_string(xref_start):utf8,
    "\n%%EOF\n",
  >>
}

fn render_info_object(id: Int, info: Info) -> Object {
  let date_value = fn(dt) { String(format_pdf_date(dt)) }
  let dictionary =
    []
    |> optional_property("Title", info.title, String)
    |> optional_property("Author", info.author, String)
    |> optional_property("Subject", info.subject, String)
    |> optional_property("Keywords", info.keywords, String)
    |> optional_property("Creator", info.creator, String)
    |> optional_property("Producer", info.producer, String)
    |> optional_property("CreationDate", info.creation_time, date_value)
    |> optional_property("ModDate", info.modification_time, date_value)

  Object(id:, stream: None, dictionary:)
}

fn optional_property(
  dictionary: List(#(String, Value)),
  key: String,
  value: option.Option(a),
  to_value: fn(a) -> Value,
) -> List(#(String, Value)) {
  case value {
    None -> dictionary
    Some(v) -> [#(key, to_value(v)), ..dictionary]
  }
}

fn format_pdf_date(time: timestamp.Timestamp) -> String {
  let #(date, time_of_day) = timestamp.to_calendar(time, calendar.utc_offset)

  "D:"
  <> int.to_string(date.year)
  <> string.pad_start(int.to_string(calendar.month_to_int(date.month)), 2, "0")
  <> string.pad_start(int.to_string(date.day), 2, "0")
  <> string.pad_start(int.to_string(time_of_day.hours), 2, "0")
  <> string.pad_start(int.to_string(time_of_day.minutes), 2, "0")
  <> string.pad_start(int.to_string(time_of_day.seconds), 2, "0")
  <> "Z"
}

import gleam/bit_array
import gleam/dict.{type Dict}
import gleam/float
import gleam/int
import gleam/list
import gleam/option.{None, Some}
import gleam/result
import gleam/set
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

/// An A3 page size, as specified by ISO 216.
///
pub const size_a3 = PageSize(width: 842.0, height: 1191.0)

/// An A4 page size, as specified by ISO 216.
///
pub const size_a4 = PageSize(width: 595.0, height: 842.0)

/// An A5 page size, as specified by ISO 216.
///
pub const size_a5 = PageSize(width: 420.0, height: 595.0)

/// The "letter" size, according to the American paper sizes standard.
///
pub const size_usa_letter = PageSize(width: 612.0, height: 792.0)

/// The "legal" size, according to the American paper sizes standard.
///
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

/// An open path made up of lines. This can be drawn as is, or closed to form a
/// shape which can have a fill.
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

/// A shape made from one or more closed paths.
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

/// An image to be drawn on a page.
///
pub opaque type Image {
  Image(
    data: BitArray,
    file_width: Int,
    file_height: Int,
    x: Float,
    y: Float,
    render_width: option.Option(Float),
    render_height: option.Option(Float),
  )
}

/// Errors that can occur when creating an image.
///
pub type ImageError {
  /// The image format is recognised but not supported.
  UnsupportedImageFormat(filetype: String)
  /// The image format is not recognised.
  UnknownImageFormat
}

type Content {
  ContentText(Text)
  ContentRectangle(Rectangle)
  ContentPath(Path)
  ContentShape(Shape)
  ContentJpegImage(Image)
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
  Document(..document, pages: [page, ..document.pages])
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
/// The font must be the name of one of the 14 standard PDF fonts.
///
/// - Courier,
/// - Courier-Bold,
/// - Courier-Oblique,
/// - Courier-BoldOblique
/// - Helvetica,
/// - Helvetica-Bold,
/// - Helvetica-Oblique,
/// - Helvetica-BoldOblique
/// - Times-Roman,
/// - Times-Bold,
/// - Times-Italic,
/// - Times-BoldItalic
/// - Symbol
/// - ZapfDingbats
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
  Page(..page, contents: [ContentText(text), ..page.contents])
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
  Page(..page, contents: [ContentRectangle(rectangle), ..page.contents])
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
  Path(..path, operations: [LineTo(x, y), ..path.operations])
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
  Page(..page, contents: [ContentPath(path), ..page.contents])
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
  Page(..page, contents: [ContentShape(shape), ..page.contents])
}

/// Create an image from JPEG data.
///
/// Currently only JPEG images are supported. Returns an error if the data is
/// not valid JPEG.
///
pub fn image(data: BitArray) -> Result(Image, ImageError) {
  case parse_image_dimensions(data) {
    Ok(#(width, height)) ->
      Ok(Image(
        data: data,
        file_width: width,
        file_height: height,
        x: 0.0,
        y: 0.0,
        render_width: None,
        render_height: None,
      ))
    Error(e) -> Error(e)
  }
}

/// Set the position of an image on the page.
///
/// The position is from the bottom-left of the page.
///
pub fn image_position(image: Image, x x: Float, y y: Float) -> Image {
  Image(..image, x: x, y: y)
}

/// Set the rendered width of an image.
///
/// If only width is set, the height scales proportionally to preserve the
/// aspect ratio.
///
pub fn image_width(image: Image, width: Float) -> Image {
  Image(..image, render_width: Some(width))
}

/// Set the rendered height of an image.
///
/// If only height is set, the width scales proportionally to preserve the
/// aspect ratio.
///
pub fn image_height(image: Image, height: Float) -> Image {
  Image(..image, render_height: Some(height))
}

/// Add an image to the page.
///
pub fn add_image(page: Page, image: Image) -> Page {
  Page(..page, contents: [ContentJpegImage(image), ..page.contents])
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
  let pages = list.reverse(document.pages)
  let page_count = list.length(pages)
  let page_ids = list.range(3, 3 + page_count - 1)
  let page_refs = list.map(page_ids, Reference)

  let catalog =
    Object(1, None, [#("Type", Name("Catalog")), #("Pages", Reference(2))])

  let pages_object =
    Object(2, None, [
      #("Type", Name("Pages")),
      #("Kids", Array(page_refs)),
      #("Count", Int(page_count)),
    ])

  let #(page_objects, _) =
    list.fold(list.zip(pages, page_ids), #([], 3 + page_count), fn(acc, pair) {
      let #(objects, next_id) = acc
      let #(page, page_id) = pair
      let #(page_object, content_object, font_objects, next_id) =
        page_to_objects(page, page_id, next_id, document)
      let objects =
        list.flatten([objects, [page_object, content_object], font_objects])
      #(objects, next_id)
    })

  [catalog, pages_object, ..page_objects]
}

fn page_to_objects(
  page: Page,
  page_id: Int,
  next_id: Int,
  document: Document,
) -> #(Object, Object, List(Object), Int) {
  let contents = list.reverse(page.contents)
  let content_id = next_id
  let #(fonts, images) = collect_assets(contents, document.default_font)
  let font_start_id = next_id + 1
  let size = option.unwrap(page.size, document.default_page_size)

  let #(font_dict, font_objects, next_id) =
    list.fold(
      list.index_map(fonts, fn(font, i) { #(font, i) }),
      #([], [], font_start_id),
      fn(acc, pair) {
        let #(dict, objs, object_id) = acc
        let #(font, index) = pair
        let font_key = "F" <> int.to_string(index + 1)
        let font_object =
          Object(object_id, None, [
            #("Type", Name("Font")),
            #("Subtype", Name("Type1")),
            #("BaseFont", Name(font)),
            #("Encoding", Name("WinAnsiEncoding")),
          ])
        #(
          [#(font_key, Reference(object_id)), ..dict],
          [font_object, ..objs],
          object_id + 1,
        )
      },
    )

  let #(image_dict, image_objects, next_id) =
    list.fold(
      list.index_map(images, fn(image, i) { #(image, i) }),
      #([], [], next_id),
      fn(acc, pair) {
        let #(dict, objs, object_id) = acc
        let #(image, index) = pair
        let image_key = "Im" <> int.to_string(index + 1)
        let image_object =
          Object(object_id, Some(image.data), [
            #("Type", Name("XObject")),
            #("Subtype", Name("Image")),
            #("Width", Int(image.file_width)),
            #("Height", Int(image.file_height)),
            #("ColorSpace", Name("DeviceRGB")),
            #("BitsPerComponent", Int(8)),
            #("Filter", Name("DCTDecode")),
          ])
        #(
          [#(image_key, Reference(object_id)), ..dict],
          [image_object, ..objs],
          object_id + 1,
        )
      },
    )

  let font_indexes = list.index_fold(fonts, dict.new(), dict.insert)
  let image_indexes =
    list.index_fold(images, dict.new(), fn(images, image, index) {
      dict.insert(images, image.data, index)
    })
  let content_stream =
    render_content_stream(contents, document, font_indexes, image_indexes)

  let resources = case image_dict {
    [] -> [#("Font", Dictionary(font_dict))]
    _ -> [
      #("Font", Dictionary(font_dict)),
      #("XObject", Dictionary(image_dict)),
    ]
  }

  let page_object =
    Object(page_id, None, [
      #("Type", Name("Page")),
      #("Parent", Reference(2)),
      #(
        "MediaBox",
        Array([Int(0), Int(0), Float(size.width), Float(size.height)]),
      ),
      #("Resources", Dictionary(resources)),
      #("Contents", Reference(content_id)),
    ])

  let content_object = Object(content_id, Some(content_stream), [])

  let objects =
    list.flatten([list.reverse(font_objects), list.reverse(image_objects)])
  #(page_object, content_object, objects, next_id)
}

fn collect_assets(
  contents: List(Content),
  default_font: String,
) -> #(List(String), List(Image)) {
  let #(fonts, images) =
    list.fold(contents, #(set.new(), []), fn(assets, content) {
      case content {
        ContentRectangle(_) -> assets
        ContentPath(_) -> assets
        ContentShape(_) -> assets
        ContentText(Text(font:, ..)) -> {
          let font = option.unwrap(font, default_font)
          let fonts = set.insert(assets.0, font)
          #(fonts, assets.1)
        }
        ContentJpegImage(image) -> {
          let images = case
            list.find(assets.1, fn(i: Image) { i.data == image.data })
          {
            Ok(_) -> assets.1
            Error(_) -> [image, ..assets.1]
          }
          #(assets.0, images)
        }
      }
    })

  let fonts = fonts |> set.to_list |> list.sort(string.compare)
  let images = list.reverse(images)
  #(fonts, images)
}

fn render_content_stream(
  contents: List(Content),
  document: Document,
  fonts: Dict(String, Int),
  images: Dict(BitArray, Int),
) -> BitArray {
  list.fold(contents, <<>>, fn(stream, content) {
    case content {
      ContentText(text) -> render_text(stream, text, fonts, document)
      ContentRectangle(rect) -> render_rectangle(stream, rect)
      ContentPath(path) -> render_path(stream, path)
      ContentShape(shape) -> render_shape(stream, shape)
      ContentJpegImage(image) -> render_image(stream, image, images)
    }
  })
}

fn render_text(
  stream: BitArray,
  text: Text,
  fonts: Dict(String, Int),
  document: Document,
) -> BitArray {
  let Text(content:, x:, y:, font:, size:, colour:) = text
  let font = option.unwrap(font, document.default_font)
  let size = option.unwrap(size, document.default_text_size)
  let colour = option.unwrap(colour, document.default_text_colour)
  let font_index = dict.get(fonts, font) |> result.unwrap(0)
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
  let encoded_content = encode_text(<<content:utf8>>, <<>>)
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
    operations
    |> list.reverse
    |> list.fold(stream, fn(stream, op) {
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
    subpaths
    |> list.reverse
    |> list.fold(stream, fn(stream, subpath) {
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
        operations
        |> list.reverse
        |> list.fold(stream, fn(stream, op) {
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

fn render_image(
  stream: BitArray,
  image: Image,
  images: Dict(BitArray, Int),
) -> BitArray {
  let Image(
    data:,
    file_width:,
    file_height:,
    x:,
    y:,
    render_width:,
    render_height:,
  ) = image

  // Find image index by matching data
  let image_index = dict.get(images, data) |> result.unwrap(0)
  let image_key = "/Im" <> int.to_string(image_index + 1)

  // Calculate render size, preserving aspect ratio if only one dimension is set
  let aspect_ratio = int.to_float(file_width) /. int.to_float(file_height)
  let #(width, height) = case render_width, render_height {
    Some(w), Some(h) -> #(w, h)
    Some(w), None -> #(w, w /. aspect_ratio)
    None, Some(h) -> #(h *. aspect_ratio, h)
    None, None -> #(int.to_float(file_width), int.to_float(file_height))
  }

  // Save graphics state, set transformation matrix, draw image, restore state
  // The transformation matrix [width 0 0 height x y] scales and positions the image
  <<
    stream:bits,
    "q\n",
    render_float(width):utf8,
    " 0 0 ",
    render_float(height):utf8,
    " ",
    render_float(x):utf8,
    " ",
    render_float(y):utf8,
    " cm\n",
    image_key:utf8,
    " Do\nQ\n",
  >>
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
/// TODO: embed portions of fonts as needed in order to support more
/// characters.
///
fn encode_text(in: BitArray, out: BitArray) -> BitArray {
  case in {
    <<>> -> out

    // ASCII range (U+0000-U+007F) - single byte, same in both encodings
    <<c, rest:bytes>> if c <= 127 -> encode_text(rest, <<out:bits, c>>)

    // Latin-1 Supplement (U+00A0-U+00FF) encoded as 2 bytes in UTF-8
    // U+00A0-U+00BF: C2 A0-BF -> A0-BF
    <<0xC2, c, rest:bytes>> if c >= 0xA0 -> encode_text(rest, <<out:bits, c>>)
    // U+00C0-U+00FF: C3 80-BF -> C0-FF
    <<0xC3, c, rest:bytes>> -> encode_text(rest, <<out:bits, { c + 0x40 }>>)

    // Special WinAnsi mappings (2-byte UTF-8 sequences)
    // Œ
    <<0xC5, 0x92, rest:bytes>> -> encode_text(rest, <<out:bits, 0x8C>>)
    // œ
    <<0xC5, 0x93, rest:bytes>> -> encode_text(rest, <<out:bits, 0x9C>>)
    // Š
    <<0xC5, 0xA0, rest:bytes>> -> encode_text(rest, <<out:bits, 0x8A>>)
    // š
    <<0xC5, 0xA1, rest:bytes>> -> encode_text(rest, <<out:bits, 0x9A>>)
    // Ÿ
    <<0xC5, 0xB8, rest:bytes>> -> encode_text(rest, <<out:bits, 0x9F>>)
    // Ž
    <<0xC5, 0xBD, rest:bytes>> -> encode_text(rest, <<out:bits, 0x8E>>)
    // ž
    <<0xC5, 0xBE, rest:bytes>> -> encode_text(rest, <<out:bits, 0x9E>>)
    // ƒ
    <<0xC6, 0x92, rest:bytes>> -> encode_text(rest, <<out:bits, 0x83>>)
    // ˆ
    <<0xCB, 0x86, rest:bytes>> -> encode_text(rest, <<out:bits, 0x88>>)
    // ˜
    <<0xCB, 0x9C, rest:bytes>> -> encode_text(rest, <<out:bits, 0x98>>)

    // Special WinAnsi mappings (3-byte UTF-8 sequences)
    // –
    <<0xE2, 0x80, 0x93, rest:bytes>> -> encode_text(rest, <<out:bits, 0x96>>)
    // —
    <<0xE2, 0x80, 0x94, rest:bytes>> -> encode_text(rest, <<out:bits, 0x97>>)
    // '
    <<0xE2, 0x80, 0x98, rest:bytes>> -> encode_text(rest, <<out:bits, 0x91>>)
    // '
    <<0xE2, 0x80, 0x99, rest:bytes>> -> encode_text(rest, <<out:bits, 0x92>>)
    // ‚
    <<0xE2, 0x80, 0x9A, rest:bytes>> -> encode_text(rest, <<out:bits, 0x82>>)
    // "
    <<0xE2, 0x80, 0x9C, rest:bytes>> -> encode_text(rest, <<out:bits, 0x93>>)
    // "
    <<0xE2, 0x80, 0x9D, rest:bytes>> -> encode_text(rest, <<out:bits, 0x94>>)
    // „
    <<0xE2, 0x80, 0x9E, rest:bytes>> -> encode_text(rest, <<out:bits, 0x84>>)
    // †
    <<0xE2, 0x80, 0xA0, rest:bytes>> -> encode_text(rest, <<out:bits, 0x86>>)
    // ‡
    <<0xE2, 0x80, 0xA1, rest:bytes>> -> encode_text(rest, <<out:bits, 0x87>>)
    // •
    <<0xE2, 0x80, 0xA2, rest:bytes>> -> encode_text(rest, <<out:bits, 0x95>>)
    // …
    <<0xE2, 0x80, 0xA6, rest:bytes>> -> encode_text(rest, <<out:bits, 0x85>>)
    // ‰
    <<0xE2, 0x80, 0xB0, rest:bytes>> -> encode_text(rest, <<out:bits, 0x89>>)
    // ‹
    <<0xE2, 0x80, 0xB9, rest:bytes>> -> encode_text(rest, <<out:bits, 0x8B>>)
    // ›
    <<0xE2, 0x80, 0xBA, rest:bytes>> -> encode_text(rest, <<out:bits, 0x9B>>)
    // €
    <<0xE2, 0x82, 0xAC, rest:bytes>> -> encode_text(rest, <<out:bits, 0x80>>)
    // ™
    <<0xE2, 0x84, 0xA2, rest:bytes>> -> encode_text(rest, <<out:bits, 0x99>>)

    <<c, rest:bytes>> -> encode_text(rest, <<out:bits, c>>)

    rest -> <<out:bits, rest:bits>>
  }
}

fn parse_image_dimensions(data: BitArray) -> Result(#(Int, Int), ImageError) {
  case data {
    // JPEG: starts with FF D8
    <<0xFF, 0xD8, rest:bytes>> -> parse_jpeg_dimensions(rest)
    // PNG: starts with 89 50 4E 47 0D 0A 1A 0A
    <<0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, _:bytes>> ->
      Error(UnsupportedImageFormat("PNG"))
    // GIF: starts with GIF8
    <<0x47, 0x49, 0x46, 0x38, _:bytes>> -> Error(UnsupportedImageFormat("GIF"))
    // BMP: starts with BM
    <<0x42, 0x4D, _:bytes>> -> Error(UnsupportedImageFormat("BMP"))
    // WebP: starts with RIFF....WEBP
    <<0x52, 0x49, 0x46, 0x46, _, _, _, _, 0x57, 0x45, 0x42, 0x50, _:bytes>> ->
      Error(UnsupportedImageFormat("WebP"))
    _ -> Error(UnknownImageFormat)
  }
}

fn parse_jpeg_dimensions(data: BitArray) -> Result(#(Int, Int), ImageError) {
  case data {
    // End of data without finding SOF
    <<>> | <<_>> -> Error(UnknownImageFormat)

    // SOF markers (0xFFC0-0xFFCF, except 0xFFC4 which is DHT)
    // Format: FF Cx LENGTH(2) PRECISION(1) HEIGHT(2) WIDTH(2)
    <<
      0xFF,
      marker,
      _:bytes-size(2),
      _,
      height:big-size(16),
      width:big-size(16),
      _:bytes,
    >>
      if marker >= 0xC0 && marker <= 0xCF && marker != 0xC4
    -> Ok(#(width, height))

    // Skip other markers (they have length field)
    <<0xFF, marker, length:big-size(16), rest:bytes>> if marker != 0x00 -> {
      // Length includes the 2 length bytes, so skip length - 2 more bytes
      let skip_count = length - 2
      case rest {
        <<_:bytes-size(skip_count), rest:bytes>> -> parse_jpeg_dimensions(rest)
        _ -> Error(UnknownImageFormat)
      }
    }

    // Skip any other bytes
    <<_, rest:bytes>> -> parse_jpeg_dimensions(rest)

    _ -> Error(UnknownImageFormat)
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

import gleam/bit_array
import gleam/float
import gleam/int
import gleam/list
import gleam/option.{None, Some}
import gleam/string
import gleam/time/calendar
import gleam/time/duration

//
// User facing API
//

pub type Document {
  Document(pages: List(Page))
}

pub type Page {
  Page(
    /// Width in points (1/72 inch)
    width: Float,
    /// Height in points (1/72 inch)
    height: Float,
    contents: List(Content),
  )
}

pub type Content {
  DrawText(
    /// Text to draw
    text: String,
    /// X position in points
    x: Float,
    /// Y position
    y: Float,
    /// Font to use
    font: String,
    /// Font size in points
    size: Float,
  )
}

/// Document metadata stored in the PDF Info dictionary.
/// All fields are optional.
pub type Info {
  Info(
    /// Document title
    title: option.Option(String),
    /// Person who created the content
    author: option.Option(String),
    /// Subject of the document
    subject: option.Option(String),
    /// Keywords associated with the document
    keywords: option.Option(String),
    /// Application that created the original content
    creator: option.Option(String),
    /// Application that produced the PDF (e.g., "Paddlefish")
    producer: option.Option(String),
    /// When the document was created
    creation_date: option.Option(
      #(calendar.Date, calendar.TimeOfDay, duration.Duration),
    ),
    /// When the document was last modified
    modification_time: option.Option(
      #(calendar.Date, calendar.TimeOfDay, duration.Duration),
    ),
  )
}

//
// Intemediate representation
//

/// An indirect PDF object, e.g., `4 0 obj ... endobj`
pub type Object {
  Object(
    /// The object id number. There's also a "generation", but since we are not
    /// editing PDFs this will always be 0.
    id: Int,
    /// The raw stream content (e.g., text or graphics commands)
    /// If this is present then /Length will be added to the rendered dictionary
    /// by the renderer
    stream: option.Option(BitArray),
    /// Any fields for the object `<< /Key Value >>`
    dictionary: List(#(String, Value)),
  )
}

/// Primitive values usable in PDF dictionaries, arrays, etc.
pub type Value {
  /// Indirect reference: `3 0 R`
  Reference(reference: Int)
  /// Name object: `/Helvetica`, `/F1`
  Name(name: String)
  /// String literal: `(Hello)`
  String(value: String)
  /// Numeric literal: `12.0`, `72.5`
  Float(value: Float)
  /// Numeric literal: `12`, `72`
  Int(value: Int)
  /// Boolean value: `true` or `false`
  Bool(value: Bool)
  /// Null value
  Null
  /// Array of values: `[ ... ]`
  Array(elements: List(Value))
  /// Inline dictionary (rare in top-level IR)
  Dictionary(values: List(#(String, Value)))
}

//
// IR to PDF
//

/// Renders a list of `Object` values into a complete PDF binary.
/// Assumes object 1 is the /Root catalog.
pub fn render_pdf(objects: List(Object), info: Info) -> BitArray {
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
    Float(f) -> <<pdf:bits, float.to_string(f):utf8>>
    Int(f) -> <<pdf:bits, int.to_string(f):utf8>>
    Bool(True) -> <<pdf:bits, "true">>
    Bool(False) -> <<pdf:bits, "false">>
    Null -> <<pdf:bits, "null">>
    Array(array) -> render_array(pdf, array)
    Dictionary(pairs) -> render_dictionary(pdf, pairs)
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
    |> optional_property("CreationDate", info.creation_date, date_value)
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

fn format_pdf_date(
  datetime: #(calendar.Date, calendar.TimeOfDay, duration.Duration),
) -> String {
  let #(date, time, offset) = datetime
  let offset_minutes = float.truncate(duration.to_seconds(offset)) / 60

  let tz = case offset_minutes {
    0 -> "Z"
    _ -> {
      let sign = case offset_minutes >= 0 {
        True -> "+"
        False -> "-"
      }
      let abs_minutes = int.absolute_value(offset_minutes)
      let hours = abs_minutes / 60
      let mins = abs_minutes % 60
      sign
      <> string.pad_start(int.to_string(hours), 2, "0")
      <> "'"
      <> string.pad_start(int.to_string(mins), 2, "0")
      <> "'"
    }
  }

  "D:"
  <> int.to_string(date.year)
  <> string.pad_start(int.to_string(calendar.month_to_int(date.month)), 2, "0")
  <> string.pad_start(int.to_string(date.day), 2, "0")
  <> string.pad_start(int.to_string(time.hours), 2, "0")
  <> string.pad_start(int.to_string(time.minutes), 2, "0")
  <> string.pad_start(int.to_string(time.seconds), 2, "0")
  <> tz
}

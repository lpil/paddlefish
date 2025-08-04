import gleam/bit_array
import gleam/float
import gleam/int
import gleam/list
import gleam/option.{None, Some}
import gleam/string

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
pub fn render_pdf(objects: List(Object)) -> BitArray {
  let pdf = <<"%PDF-1.4\n">>
  let #(pdf, offsets) = render_objects(pdf, objects, [])
  let xref_start = bit_array.byte_size(pdf)
  let pdf = render_xref(pdf, offsets)
  let pdf = render_trailer(pdf, list.length(objects), xref_start)
  pdf
}

fn render_objects(
  pdf: BitArray,
  objects: List(Object),
  offsets: List(Int),
) -> #(BitArray, List(Int)) {
  case objects {
    [] -> #(pdf, list.reverse(offsets))
    [Object(id:, stream:, dictionary:), ..objects] -> {
      let offsets = [bit_array.byte_size(pdf), ..offsets]
      let pdf = <<pdf:bits, int.to_string(id):utf8, " 0 obj\n">>

      // If we have a content stream then the length must be included in the dictionary
      let dictionary = case stream {
        None -> dictionary
        Some(stream) -> {
          [#("Length", Int(bit_array.byte_size(stream))), ..dictionary]
        }
      }

      // Render the dictionary
      let pdf = render_dictionary(pdf, dictionary)
      let pdf = <<pdf:bits, "\n">>

      // Render the content stream, if there is one
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

      render_objects(pdf, objects, offsets)
    }
  }
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

fn render_trailer(pdf: BitArray, count: Int, xref_start: Int) -> BitArray {
  <<
    pdf:bits,
    "trailer\n",
    "<<\n",
    "/Size ",
    int.to_string(count + 1):utf8,
    "\n",
    "/Root 1 0 R\n",
    ">>\n",
    "startxref\n",
    int.to_string(xref_start):utf8,
    "\n%%EOF\n",
  >>
}

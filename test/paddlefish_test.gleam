import birdie
import gleam/bit_array
import gleam/crypto
import gleam/option.{Some}
import gleam/time/calendar
import gleam/time/duration
import gleeunit
import paddlefish/pdf.{
  type Object, Array, Dictionary, Info, Int, Name, Object, Reference,
}

pub fn main() -> Nil {
  gleeunit.main()
}

pub fn pdf_with_info_test() {
  let objects: List(Object) = [
    Object(1, option.None, [
      #("Type", Name("Catalog")),
      #("Pages", Reference(2)),
    ]),

    Object(2, option.None, [
      #("Type", Name("Pages")),
      #("Kids", Array([Reference(3)])),
      #("Count", Int(1)),
    ]),

    Object(3, option.None, [
      #("Type", Name("Page")),
      #("Parent", Reference(2)),
      #("MediaBox", Array([Int(0), Int(0), Int(200), Int(200)])),
      #(
        "Resources",
        Dictionary([#("Font", Dictionary([#("F1", Reference(5))]))]),
      ),
      #("Contents", Reference(4)),
    ]),

    // Content stream object (4 obj)
    Object(
      4,
      option.Some(<<
        "BT
/F1 10 Tf
20 20 Td
(This PDF was created with Gleam) Tj
ET
",
      >>),
      [],
    ),

    // Font object (5 obj)
    Object(5, option.None, [
      #("Type", Name("Font")),
      #("Subtype", Name("Type1")),
      #("BaseFont", Name("Helvetica")),
    ]),
  ]

  let info =
    Info(
      title: Some("Hello, Joe!"),
      author: Some("Louis Pilfold"),
      subject: Some("A test PDF document"),
      keywords: Some("gleam, pdf, paddlefish"),
      creator: Some("Paddlefish Test Suite"),
      producer: Some("Paddlefish"),
      creation_date: Some(#(
        calendar.Date(2026, calendar.February, 10),
        calendar.TimeOfDay(14, 30, 0, 0),
        duration.minutes(0),
      )),
      modification_time: Some(#(
        calendar.Date(2026, calendar.February, 10),
        calendar.TimeOfDay(15, 45, 30, 0),
        duration.minutes(0),
      )),
    )

  pdf.render(objects, info)
  |> bit_array_to_lossy_string
  |> birdie.snap("pdf_with_info_test")
}

pub fn bit_array_to_lossy_string(input: BitArray) -> String {
  lossy_string(input, "")
}

fn lossy_string(input: BitArray, output: String) -> String {
  case input {
    <<codepoint:utf8_codepoint, input:bytes>> -> {
      let assert Ok(new) = bit_array.to_string(<<codepoint:utf8_codepoint>>)
      lossy_string(input, output <> new)
    }
    <<first, input:bytes>> -> {
      let #(data, input) = take_non_utf8(input, <<first>>)
      let hash =
        crypto.hash(crypto.Sha256, data) |> bit_array.base64_encode(False)
      lossy_string(input, output <> "{binary:" <> hash <> "}")
    }
    <<>> -> output
    _ -> panic as "non-byte aligned string"
  }
}

fn take_non_utf8(input: BitArray, output: BitArray) -> #(BitArray, BitArray) {
  case input {
    <<_:utf8_codepoint, _:bytes>> -> #(output, input)
    <<data, input:bytes>> -> take_non_utf8(input, <<output:bits, data>>)
    _ -> panic as "non-byte aligned string"
  }
}

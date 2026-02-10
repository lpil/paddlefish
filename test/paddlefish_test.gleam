import gleam/bit_array
import gleam/io
import gleam/option.{Some}
import gleam/result
import gleam/time/calendar
import gleam/time/duration
import paddlefish.{
  type Object, Array, Dictionary, Info, Int, Name, Object, Reference,
}

pub fn main() -> Nil {
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

  io.println(
    bit_array.to_string(paddlefish.render_pdf(objects, info))
    |> result.unwrap(""),
  )

  Nil
}

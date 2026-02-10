import birdie
import gleam/bit_array
import gleam/crypto
import gleam/time/calendar
import gleam/time/duration
import gleeunit
import paddlefish as pdf

pub fn main() -> Nil {
  gleeunit.main()
}

pub fn pdf_with_info_test() {
  let page =
    pdf.new_page(200.0, 200.0)
    |> pdf.draw_text(
      "This PDF was created with Gleam",
      at: #(20.0, 20.0),
      font: "Helvetica",
      size: 10.0,
    )

  pdf.new_document()
  |> pdf.title("Hello, Joe!")
  |> pdf.author("Louis Pilfold")
  |> pdf.subject("A test PDF document")
  |> pdf.keywords("gleam, pdf, paddlefish")
  |> pdf.creator("Paddlefish Test Suite")
  |> pdf.producer("Paddlefish")
  |> pdf.created_at(
    calendar.Date(2026, calendar.February, 10),
    calendar.TimeOfDay(14, 30, 0, 0),
    duration.minutes(0),
  )
  |> pdf.modified_at(
    calendar.Date(2026, calendar.February, 10),
    calendar.TimeOfDay(15, 45, 30, 0),
    duration.minutes(0),
  )
  |> pdf.add_page(page)
  |> pdf.render
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

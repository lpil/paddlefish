import birdie
import gleam/bit_array
import gleam/crypto
import gleam/time/timestamp
import gleeunit
import paddlefish as pdf
import simplifile

pub fn main() -> Nil {
  gleeunit.main()
}

pub fn pdf_empty_page_test() {
  let bytes =
    pdf.new_document()
    |> pdf.add_page(pdf.new_page())
    |> pdf.render

  let assert Ok(_) =
    simplifile.write_bits("pdfs/pdf_empty_page_test.pdf", bytes)

  bytes
  |> bit_array_to_lossy_string
  |> birdie.snap("pdf_empty_page_test")
}

pub fn pdf_different_page_sizes_test() {
  let bytes =
    pdf.new_document()
    |> pdf.add_page(pdf.new_page() |> pdf.page_size(pdf.size_a4))
    |> pdf.add_page(pdf.new_page() |> pdf.page_size(pdf.size_usa_letter))
    |> pdf.render

  let assert Ok(_) =
    simplifile.write_bits("pdfs/pdf_different_page_sizes_test.pdf", bytes)

  bytes
  |> bit_array_to_lossy_string
  |> birdie.snap("pdf_different_page_sizes_test")
}

pub fn pdf_with_defaults_test() {
  let bytes =
    pdf.new_document()
    |> pdf.default_page_size(pdf.PageSize(200.0, 200.0))
    |> pdf.add_page(
      pdf.new_page()
      |> pdf.add_text(pdf.text("Hello using defaults", at: #(20.0, 20.0))),
    )
    |> pdf.render

  let assert Ok(_) =
    simplifile.write_bits("pdfs/pdf_with_defaults_test.pdf", bytes)

  bytes
  |> bit_array_to_lossy_string
  |> birdie.snap("pdf_with_defaults_test")
}

pub fn pdf_with_custom_text_defaults_test() {
  let bytes =
    pdf.new_document()
    |> pdf.default_page_size(pdf.PageSize(200.0, 200.0))
    |> pdf.default_font("Times-Roman")
    |> pdf.default_text_size(24.0)
    |> pdf.add_page(
      pdf.new_page()
      |> pdf.add_text(pdf.text("Using custom defaults", at: #(20.0, 100.0))),
    )
    |> pdf.render

  let assert Ok(_) =
    simplifile.write_bits("pdfs/pdf_with_custom_text_defaults_test.pdf", bytes)

  bytes
  |> bit_array_to_lossy_string
  |> birdie.snap("pdf_with_custom_text_defaults_test")
}

pub fn pdf_with_info_test() {
  let bytes =
    pdf.new_document()
    |> pdf.default_page_size(pdf.PageSize(200.0, 200.0))
    |> pdf.title("Hello, Joe!")
    |> pdf.author("Louis Pilfold")
    |> pdf.subject("A test PDF document")
    |> pdf.keywords("gleam, pdf, paddlefish")
    |> pdf.creator("Paddlefish Test Suite")
    |> pdf.producer("Paddlefish")
    |> pdf.created_at(timestamp.from_unix_seconds(1_770_733_800))
    |> pdf.modified_at(timestamp.from_unix_seconds(1_770_738_330))
    |> pdf.add_page(
      pdf.new_page()
      |> pdf.add_text(
        pdf.text("This PDF was created with Gleam", at: #(20.0, 20.0))
        |> pdf.font("Helvetica")
        |> pdf.text_size(10.0),
      ),
    )
    |> pdf.render

  let assert Ok(_) =
    simplifile.write_bits("pdfs/pdf_with_info_test.pdf", bytes)

  bytes
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

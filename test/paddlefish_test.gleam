import birdie
import gleam/bit_array
import gleam/crypto
import gleam/int
import gleam/string
import gleam/time/timestamp
import gleeunit
import paddlefish as pdf
import simplifile

pub fn main() -> Nil {
  gleeunit.main()
}

pub fn portrait_already_portrait_test() {
  assert pdf.portrait(pdf.PageSize(100.0, 200.0)) == pdf.PageSize(100.0, 200.0)
}

pub fn portrait_from_landscape_test() {
  assert pdf.portrait(pdf.PageSize(200.0, 100.0)) == pdf.PageSize(100.0, 200.0)
}

pub fn portrait_square_test() {
  assert pdf.portrait(pdf.PageSize(100.0, 100.0)) == pdf.PageSize(100.0, 100.0)
}

pub fn landscape_already_landscape_test() {
  assert pdf.landscape(pdf.PageSize(200.0, 100.0)) == pdf.PageSize(200.0, 100.0)
}

pub fn landscape_from_portrait_test() {
  assert pdf.landscape(pdf.PageSize(100.0, 200.0)) == pdf.PageSize(200.0, 100.0)
}

pub fn landscape_square_test() {
  assert pdf.landscape(pdf.PageSize(100.0, 100.0)) == pdf.PageSize(100.0, 100.0)
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
    |> pdf.add_page(
      pdf.new_page()
      |> pdf.add_text(pdf.text("Hello using defaults", x: 20.0, y: 20.0)),
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
    |> pdf.default_font("Times-Roman")
    |> pdf.default_text_size(24.0)
    |> pdf.add_page(
      pdf.new_page()
      |> pdf.add_text(pdf.text("Using custom defaults", x: 20.0, y: 100.0)),
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
        pdf.text("This PDF was created with Gleam", x: 20.0, y: 20.0)
        |> pdf.font("Helvetica")
        |> pdf.text_size(10.0),
      ),
    )
    |> pdf.render

  let assert Ok(_) = simplifile.write_bits("pdfs/pdf_with_info_test.pdf", bytes)

  bytes
  |> bit_array_to_lossy_string
  |> birdie.snap("pdf_with_info_test")
}

pub fn pdf_with_coloured_text_test() {
  let bytes =
    pdf.new_document()
    |> pdf.add_page(
      pdf.new_page()
      |> pdf.add_text(
        pdf.text("Red", x: 72.0, y: 700.0)
        |> pdf.text_colour(pdf.Rgb(1.0, 0.0, 0.0)),
      )
      |> pdf.add_text(
        pdf.text("Orange", x: 72.0, y: 650.0)
        |> pdf.text_colour(pdf.Rgb(1.0, 0.5, 0.0)),
      )
      |> pdf.add_text(
        pdf.text("Yellow", x: 72.0, y: 600.0)
        |> pdf.text_colour(pdf.Rgb(1.0, 1.0, 0.0)),
      )
      |> pdf.add_text(
        pdf.text("Green", x: 72.0, y: 550.0)
        |> pdf.text_colour(pdf.Rgb(0.0, 1.0, 0.0)),
      )
      |> pdf.add_text(
        pdf.text("Cyan", x: 72.0, y: 500.0)
        |> pdf.text_colour(pdf.Rgb(0.0, 1.0, 1.0)),
      )
      |> pdf.add_text(
        pdf.text("Blue", x: 72.0, y: 450.0)
        |> pdf.text_colour(pdf.Rgb(0.0, 0.0, 1.0)),
      )
      |> pdf.add_text(
        pdf.text("Violet", x: 72.0, y: 400.0)
        |> pdf.text_colour(pdf.Rgb(0.5, 0.0, 1.0)),
      ),
    )
    |> pdf.render

  let assert Ok(_) =
    simplifile.write_bits("pdfs/pdf_with_coloured_text_test.pdf", bytes)

  bytes
  |> bit_array_to_lossy_string
  |> birdie.snap("pdf_with_coloured_text_test")
}

pub fn pdf_with_zig_zag_line_test() {
  let bytes =
    pdf.new_document()
    |> pdf.add_page(
      pdf.new_page()
      |> pdf.add_path(
        pdf.path(x: 72.0, y: 700.0)
        |> pdf.line(x: 122.0, y: 750.0)
        |> pdf.line(x: 172.0, y: 700.0)
        |> pdf.line(x: 222.0, y: 750.0)
        |> pdf.line(x: 272.0, y: 700.0)
        |> pdf.path_stroke_colour(pdf.Rgb(1.0, 0.4, 0.7))
        |> pdf.path_line_width(2.0),
      ),
    )
    |> pdf.render

  let assert Ok(_) =
    simplifile.write_bits("pdfs/pdf_with_zig_zag_line_test.pdf", bytes)

  bytes
  |> bit_array_to_lossy_string
  |> birdie.snap("pdf_with_zig_zag_line_test")
}

pub fn pdf_with_triangle_test() {
  let bytes =
    pdf.new_document()
    |> pdf.add_page(
      pdf.new_page()
      |> pdf.add_shape(
        pdf.path(x: 72.0, y: 500.0)
        |> pdf.line(x: 272.0, y: 500.0)
        |> pdf.line(x: 172.0, y: 700.0)
        |> pdf.shape
        |> pdf.shape_fill_colour(pdf.Rgb(0.4, 0.8, 0.9))
        |> pdf.shape_stroke_colour(pdf.Rgb(0.0, 0.5, 0.6))
        |> pdf.shape_line_width(2.0),
      ),
    )
    |> pdf.render

  let assert Ok(_) =
    simplifile.write_bits("pdfs/pdf_with_triangle_test.pdf", bytes)

  bytes
  |> bit_array_to_lossy_string
  |> birdie.snap("pdf_with_triangle_test")
}

pub fn pdf_with_triangle_donut_test() {
  let outer =
    pdf.path(x: 72.0, y: 400.0)
    |> pdf.line(x: 372.0, y: 400.0)
    |> pdf.line(x: 222.0, y: 700.0)

  let inner =
    pdf.path(x: 172.0, y: 450.0)
    |> pdf.line(x: 272.0, y: 450.0)
    |> pdf.line(x: 222.0, y: 550.0)

  let bytes =
    pdf.new_document()
    |> pdf.add_page(
      pdf.new_page()
      |> pdf.add_shape(
        pdf.compound_shape([outer, inner])
        |> pdf.shape_fill_colour(pdf.Rgb(0.6, 0.4, 0.8))
        |> pdf.shape_stroke_colour(pdf.Rgb(0.3, 0.1, 0.5))
        |> pdf.shape_line_width(2.0),
      ),
    )
    |> pdf.render

  let assert Ok(_) =
    simplifile.write_bits("pdfs/pdf_with_triangle_donut_test.pdf", bytes)

  bytes
  |> bit_array_to_lossy_string
  |> birdie.snap("pdf_with_triangle_donut_test")
}

pub fn pdf_with_fill_only_shape_test() {
  let bytes =
    pdf.new_document()
    |> pdf.add_page(
      pdf.new_page()
      |> pdf.add_shape(
        pdf.path(x: 100.0, y: 500.0)
        |> pdf.line(x: 300.0, y: 500.0)
        |> pdf.line(x: 300.0, y: 700.0)
        |> pdf.line(x: 100.0, y: 700.0)
        |> pdf.shape
        |> pdf.shape_fill_colour(pdf.Rgb(0.2, 0.6, 0.4)),
      ),
    )
    |> pdf.render

  let assert Ok(_) =
    simplifile.write_bits("pdfs/pdf_with_fill_only_shape_test.pdf", bytes)

  bytes
  |> bit_array_to_lossy_string
  |> birdie.snap("pdf_with_fill_only_shape_test")
}

pub fn pdf_with_thick_stroke_shape_test() {
  let bytes =
    pdf.new_document()
    |> pdf.add_page(
      pdf.new_page()
      |> pdf.add_shape(
        pdf.path(x: 100.0, y: 500.0)
        |> pdf.line(x: 300.0, y: 500.0)
        |> pdf.line(x: 200.0, y: 700.0)
        |> pdf.shape
        |> pdf.shape_fill_colour(pdf.Rgb(1.0, 0.9, 0.6))
        |> pdf.shape_stroke_colour(pdf.Rgb(0.8, 0.4, 0.0))
        |> pdf.shape_line_width(15.0),
      ),
    )
    |> pdf.render

  let assert Ok(_) =
    simplifile.write_bits("pdfs/pdf_with_thick_stroke_shape_test.pdf", bytes)

  bytes
  |> bit_array_to_lossy_string
  |> birdie.snap("pdf_with_thick_stroke_shape_test")
}

pub fn pdf_with_rectangles_test() {
  let bytes =
    pdf.new_document()
    |> pdf.add_page(
      pdf.new_page()
      |> pdf.add_rectangle(
        pdf.rectangle(x: 72.0, y: 700.0, width: 100.0, height: 50.0)
        |> pdf.rectangle_fill_colour(pdf.Rgb(1.0, 0.0, 0.0)),
      )
      |> pdf.add_rectangle(
        pdf.rectangle(x: 72.0, y: 600.0, width: 100.0, height: 50.0)
        |> pdf.rectangle_stroke_colour(pdf.Rgb(0.0, 0.0, 1.0))
        |> pdf.rectangle_line_width(2.0),
      )
      |> pdf.add_rectangle(
        pdf.rectangle(x: 72.0, y: 500.0, width: 100.0, height: 50.0)
        |> pdf.rectangle_fill_colour(pdf.Rgb(1.0, 1.0, 0.0))
        |> pdf.rectangle_stroke_colour(pdf.Rgb(0.0, 0.0, 0.0))
        |> pdf.rectangle_line_width(3.0),
      ),
    )
    |> pdf.render

  let assert Ok(_) =
    simplifile.write_bits("pdfs/pdf_with_rectangles_test.pdf", bytes)

  bytes
  |> bit_array_to_lossy_string
  |> birdie.snap("pdf_with_rectangles_test")
}

pub fn pdf_with_special_characters_test() {
  let bytes =
    pdf.new_document()
    |> pdf.add_page(
      pdf.new_page()
      // WinAnsi special characters (mapped from higher Unicode)
      |> pdf.add_text(pdf.text(
        "Euro: €  Quotes: \"curly\" 'single'",
        x: 72.0,
        y: 750.0,
      ))
      |> pdf.add_text(pdf.text(
        "Dashes: – em — and ellipsis…",
        x: 72.0,
        y: 720.0,
      ))
      |> pdf.add_text(pdf.text("Symbols: † ‡ • ‰ ™", x: 72.0, y: 690.0))
      |> pdf.add_text(pdf.text("Letters: Œ œ Š š Ž ž Ÿ ƒ", x: 72.0, y: 660.0))
      // Latin-1 Supplement (directly mapped)
      |> pdf.add_text(pdf.text("Accents: é à ü ñ ç ø å æ", x: 72.0, y: 630.0))
      |> pdf.add_text(pdf.text("Currency: £ ¥ ¢ © ® ° ±", x: 72.0, y: 600.0))
      // Emoji - not in WinAnsi, will be replaced with ?
      |> pdf.add_text(pdf.text("Emoji: 🎉 → ?", x: 72.0, y: 550.0))
      // Other unsupported scripts
      |> pdf.add_text(pdf.text("Greek: Ω → ?", x: 72.0, y: 520.0))
      |> pdf.add_text(pdf.text("Cyrillic: Д → ?", x: 72.0, y: 490.0)),
    )
    |> pdf.render

  let assert Ok(_) =
    simplifile.write_bits("pdfs/pdf_with_special_characters_test.pdf", bytes)

  bytes
  |> bit_array_to_lossy_string
  |> birdie.snap("pdf_with_special_characters_test")
}

pub fn pdf_with_jpeg_image_test() {
  let assert Ok(image_data) =
    simplifile.read_bits("test/opera_senza_titolo.jpg")
  let assert Ok(image) = pdf.image(image_data)

  let bytes =
    pdf.new_document()
    |> pdf.add_page(
      pdf.new_page()
      // Scale by width, height preserves aspect ratio
      |> pdf.add_image(
        image
        |> pdf.image_position(x: 100.0, y: 400.0)
        |> pdf.image_width(400.0),
      )
      // Scale by both dimensions
      |> pdf.add_image(
        image
        |> pdf.image_position(x: 100.0, y: 100.0)
        |> pdf.image_width(200.0)
        |> pdf.image_height(150.0),
      ),
    )
    |> pdf.render

  let assert Ok(_) =
    simplifile.write_bits("pdfs/pdf_with_jpeg_image_test.pdf", bytes)

  bytes
  |> bit_array_to_lossy_string
  |> birdie.snap("pdf_with_jpeg_image_test")
}

pub fn image_rejects_png_test() {
  let assert Ok(data) = simplifile.read_bits("test/opera_senza_titolo.png")
  let result = pdf.image(data)
  assert result == Error(pdf.UnsupportedImageFormat("PNG"))
}

pub fn image_rejects_unknown_format_test() {
  let result = pdf.image(<<"not an image":utf8>>)
  assert result == Error(pdf.UnknownImageFormat)
}

pub fn bit_array_to_lossy_string(input: BitArray) -> String {
  lossy_string(input, "")
}

fn lossy_string(input: BitArray, output: String) -> String {
  case input {
    <<>> -> output

    // Detect "stream\n" followed by JPEG magic bytes - hash the image
    <<"stream\n":utf8, 0xFF, 0xD8, rest:bytes>> -> {
      let #(stream_data, rest) = take_until_endstream(rest, <<0xFF, 0xD8>>)
      let hash =
        crypto.hash(crypto.Sha256, stream_data)
        |> bit_array.base64_encode(False)
      lossy_string(rest, output <> "stream\n{image:" <> hash <> "}")
    }

    <<codepoint:utf8_codepoint, rest:bytes>> -> {
      let assert Ok(new) = bit_array.to_string(<<codepoint:utf8_codepoint>>)
      lossy_string(rest, output <> new)
    }

    <<byte, rest:bytes>> -> {
      let hex = int.to_base16(byte) |> string.lowercase
      lossy_string(rest, output <> "\\u{" <> hex <> "}")
    }

    _ -> panic as "non-byte aligned bit array"
  }
}

fn take_until_endstream(
  input: BitArray,
  output: BitArray,
) -> #(BitArray, BitArray) {
  case input {
    <<"\nendstream":utf8, _:bytes>> -> #(output, input)
    <<byte, rest:bytes>> -> take_until_endstream(rest, <<output:bits, byte>>)
    _ -> #(output, <<>>)
  }
}

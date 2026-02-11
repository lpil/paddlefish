import paddlefish as pdf
import simplifile

pub fn main() {
  let pink = pdf.Rgb(1.0, 0.5, 0.8)
  let dark_pink = pdf.Rgb(0.8, 0.2, 0.5)
  let light_grey = pdf.Rgb(0.95, 0.95, 0.95)
  let dark_grey = pdf.Rgb(0.3, 0.3, 0.3)
  let font = "Helvetica"
  let bold = "Helvetica-Bold"
  let italic = "Helvetica-Oblique"

  let page =
    pdf.new_page()
    // Header bar
    |> pdf.add_shape(
      pdf.path(x: 0.0, y: 780.0)
      |> pdf.line(x: 595.0, y: 780.0)
      |> pdf.line(x: 595.0, y: 842.0)
      |> pdf.line(x: 0.0, y: 842.0)
      |> pdf.shape
      |> pdf.shape_fill_colour(pink),
    )
    // Company name
    |> pdf.add_text(
      pdf.text("Gleam Corp", x: 50.0, y: 800.0)
      |> pdf.text_size(24.0)
      |> pdf.font(bold),
    )
    // Invoice title
    |> pdf.add_text(
      pdf.text("INVOICE", x: 450.0, y: 800.0)
      |> pdf.text_size(18.0)
      |> pdf.font(bold),
    )
    // Bill to section
    |> pdf.add_text(
      pdf.text("Bill to:", x: 50.0, y: 720.0)
      |> pdf.text_colour(dark_grey)
      |> pdf.font(bold),
    )
    |> pdf.add_text(
      pdf.text("A Gleamlin", x: 50.0, y: 700.0)
      |> pdf.text_colour(dark_grey),
    )
    |> pdf.add_text(
      pdf.text("3 Trains Avenue", x: 50.0, y: 685.0)
      |> pdf.text_colour(dark_grey),
    )
    |> pdf.add_text(
      pdf.text("AB12 3CD", x: 50.0, y: 670.0)
      |> pdf.text_colour(dark_grey),
    )
    // Invoice details
    |> pdf.add_text(
      pdf.text("Invoice: 001", x: 400.0, y: 720.0)
      |> pdf.text_colour(dark_grey),
    )
    |> pdf.add_text(
      pdf.text("Date: 11 Feb 2026", x: 400.0, y: 700.0)
      |> pdf.text_colour(dark_grey),
    )

  let page =
    page
    |> table_row(600.0, dark_pink, bold, "Item", "Qty", "Price", "Total")
    |> table_row(575.0, light_grey, font, "Magic", "3", "£25.00", "£75.00")
    |> table_row(550.0, dark_grey, font, "Glitter", "1,000", "£0.01", "£10.00")
    |> table_row(550.0, light_grey, font, "Pride", "1", "£100.00", "£100.00")

  let page =
    page
    // Divider line
    |> pdf.add_path(
      pdf.path(x: 350.0, y: 500.0)
      |> pdf.line(x: 545.0, y: 500.0)
      |> pdf.path_stroke_colour(dark_pink)
      |> pdf.path_line_width(1.0),
    )
    // Subtotal
    |> pdf.add_text(
      pdf.text("Subtotal:", x: 380.0, y: 475.0)
      |> pdf.text_colour(dark_grey),
    )
    |> pdf.add_text(
      pdf.text("£225.00", x: 480.0, y: 475.0)
      |> pdf.text_colour(dark_grey),
    )
    // VAT
    |> pdf.add_text(
      pdf.text("VAT (20%):", x: 380.0, y: 455.0)
      |> pdf.text_colour(dark_grey),
    )
    |> pdf.add_text(
      pdf.text("£45.00", x: 480.0, y: 455.0)
      |> pdf.text_colour(dark_grey),
    )
    // Total
    |> pdf.add_text(
      pdf.text("Total:", x: 380.0, y: 425.0)
      |> pdf.text_colour(dark_pink)
      |> pdf.text_size(16.0)
      |> pdf.font(bold),
    )
    |> pdf.add_text(
      pdf.text("£270.00", x: 470.0, y: 425.0)
      |> pdf.text_colour(dark_pink)
      |> pdf.text_size(16.0)
      |> pdf.font(bold),
    )
    // Footer
    |> pdf.add_text(
      pdf.text("Thank you!", x: 50.0, y: 100.0)
      |> pdf.text_colour(dark_grey)
      |> pdf.font(italic),
    )
    |> pdf.add_text(
      pdf.text("Gleam Corp - absolutely fabulous", x: 50.0, y: 50.0)
      |> pdf.text_colour(pink)
      |> pdf.text_size(10.0),
    )

  // Render the PDF and write it to disc
  let pdf =
    pdf.new_document()
    |> pdf.title("Invoice from Gleam Corp")
    |> pdf.default_font(font)
    |> pdf.default_text_size(12.0)
    |> pdf.add_page(page)
    |> pdf.render
  let assert Ok(_) = simplifile.write_bits("pdfs/example-invoice.pdf", pdf)
}

fn table_row(
  page: pdf.Page,
  y: Float,
  background: pdf.Colour,
  font: String,
  text1: String,
  text2: String,
  text3: String,
  text4: String,
) -> pdf.Page {
  let page =
    page
    // Table header background
    |> pdf.add_rectangle(
      pdf.rectangle(x: 50.0, y:, width: 495.0, height: 25.0)
      |> pdf.rectangle_fill_colour(background),
    )
    // Table header text
    |> pdf.add_text(
      pdf.text(text1, x: 60.0, y: y +. 7.0)
      |> pdf.font(font),
    )
    |> pdf.add_text(
      pdf.text(text2, x: 300.0, y: y +. 7.0)
      |> pdf.font(font),
    )
    |> pdf.add_text(
      pdf.text(text3, x: 380.0, y: y +. 7.0)
      |> pdf.font(font),
    )
    |> pdf.add_text(
      pdf.text(text4, x: 480.0, y: y +. 7.0)
      |> pdf.font(font),
    )
  page
}

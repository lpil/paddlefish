# paddlefish

A pure-Gleam PDF generator!

[![Package Version](https://img.shields.io/hexpm/v/paddlefish)](https://hex.pm/packages/paddlefish)
[![Hex Docs](https://img.shields.io/badge/hex-docs-ffaff3)](https://hexdocs.pm/paddlefish/)

```sh
gleam add paddlefish@1
```
```gleam
import paddlefish as pdf
import simplifile

pub fn main() -> Nil {
  pdf.new_document()
  |> pdf.title("Very Important Document")
  |> pdf.author("Lucy")
  |> pdf.add_page(
    pdf.new_page()
    |> pdf.add_text(pdf.text("Give me chocolate please", x: 20.0, y: 400.0))
  )

  let data = pdf.render(document)
  assert simplifile.write_bits("important.pdf")
}
```

Unlike other PDF generation libraries and techniques, this package does not
require any external programs or infrastructure, such as a headless Chrome
instance. This makes it easier to deploy, faster, and more memory efficient.
External software may be useful for generating more complex PDFs, but for
simple cases such as generating invoices this package is a good choice.

See the `dev/example_*` files for example usage, and documentation can be found
at <https://hexdocs.pm/paddlefish>.

Shout-out to the original majestic sea creature that inspired this package,
Ruby's [Prawn](https://github.com/prawnpdf/prawn).

# 🦘 cangaroo

Gleam bindings for the [Excansock](https://github.com/pavels/excansock) Elixir library.

[![Package Version](https://img.shields.io/hexpm/v/cangaroo)](https://hex.pm/packages/cangaroo)
[![Hex Docs](https://img.shields.io/badge/hex-docs-ffaff3)](https://hexdocs.pm/cangaroo/)

```sh
gleam add cangaroo@1
```

```gleam
import cangaroo
import cangaroo/bridge
import gleam/io
import gleam/result

pub fn main() {
  let status = {
    use socket <- result.try(
      cangaroo.start() |> result.replace_error("start failed"),
    )

    use _ <- result.try(
      cangaroo.open(socket, "vcan0") |> result.replace_error("open failed"),
    )

    io.println("Interface opened. Sending frame...")
    let frame = bridge.new_frame(0x123, <<1, 2, 3, 4>>)

    use _ <- result.try(
      cangaroo.send(socket, frame) |> result.replace_error("send failed"),
    )

    io.println("Frame sent successfully")
    Ok(Nil)
  }

  case status {
    Ok(Nil) -> io.println("Finished")
    Error(msg) -> io.println("Error: " <> msg)
  }
}```

Further documentation can be found at <https://hexdocs.pm/cangaroo>.

## Development

```sh
gleam test  # Run the tests
```

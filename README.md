# 🦘 cangaroo

[![Package Version](https://img.shields.io/hexpm/v/cangaroo)](https://hex.pm/packages/cangaroo)
[![Hex Docs](https://img.shields.io/badge/hex-docs-ffaff3)](https://hexdocs.pm/cangaroo/)

cangaroo provides Gleam bindings to the [Excansock](https://github.com/pavels/excansock) Elixir library, enabling Gleam applications to communicate with SocketCAN devices on Linux.

```sh
gleam add cangaroo@1
```

```gleam
import cangaroo
import cangaroo/bridge
import gleam/result

pub fn main() {
  use socket <- result.try(cangaroo.start())

  use _ <- result.try(cangaroo.open(socket, "can0"))

  let frame = bridge.new_frame(0x123, <<1, 2, 3, 4>>)

  let _ = cangaroo.send(socket, frame)

  cangaroo.close(socket)
}
```

## Development

```sh
gleam test  # Run the tests
```

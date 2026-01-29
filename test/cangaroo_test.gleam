import cangaroo
import cangaroo/bridge
import cangaroo/types
import gleam/erlang/process
import gleeunit
import gleeunit/should

pub fn main() -> Nil {
  gleeunit.main()
}

pub fn socket_lifecycle_test() {
  let client = cangaroo.start_link("vcan0") |> should.be_ok

  let frame = process.receive(client.subject, 1000)

  let selector =
    process.new_selector()
    |> process.select(client.subject)

  verify_filters(client.socket)
  verify_double_bind(client.socket)
}

pub fn verify_double_bind(socket: types.CanSocket) {
  todo
}

pub fn verify_filters(socket: types.CanSocket) {
  let filter = bridge.new_filter(0x123, 1)
  cangaroo.set_filters(socket, [filter]) |> should.be_ok
}

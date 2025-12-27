import cangaroo
import cangaroo/bridge
import gleeunit
import gleeunit/should

pub fn main() -> Nil {
  gleeunit.main()
}

pub fn create_frame_test() {
  let id = 0x123
  let data = <<1, 2, 3, 4>>
  let frame = bridge.new_frame(id, data)

  bridge.get_id(frame) |> should.equal(0x123)
  bridge.get_data(frame) |> should.equal(<<1, 2, 3, 4>>)
}

pub fn socket_lifecycle_test() {
  let socket = cangaroo.start() |> should.be_ok
  cangaroo.open(socket, "vcan0") |> should.be_ok

  verify_filters(socket)
  verify_double_bind(socket)

  cangaroo.close(socket)
}

pub fn verify_double_bind(socket: cangaroo.CanSocket) {
  cangaroo.open(socket, "vcan0")
  |> should.equal(Error(cangaroo.InterfaceBound))
}

pub fn verify_filters(socket: cangaroo.CanSocket) {
  let filter = bridge.new_filter(0x123, 1)
  cangaroo.set_filters(socket, [filter]) |> should.be_ok
}

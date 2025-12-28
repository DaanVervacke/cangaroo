import cangaroo/bridge
import gleam/dynamic
import gleam/dynamic/decode
import gleam/erlang/atom
import gleam/erlang/process

// EXTERNAL -----------------------------------------------------------------------

@external(erlang, "Elixir.Excansock", "start_link")
fn start_link_external() -> #(atom.Atom, process.Pid)

@external(erlang, "Elixir.Excansock", "open")
fn open_external(
  pid: process.Pid,
  interface: String,
  canfd: Bool,
) -> dynamic.Dynamic

@external(erlang, "Elixir.Excansock", "close")
fn close_external(pid: process.Pid) -> atom.Atom

@external(erlang, "Elixir.Excansock", "send")
fn send_external(pid: process.Pid, frame: bridge.CanFrame) -> atom.Atom

@external(erlang, "Elixir.Excansock", "set_loopback")
fn set_loopback_external(pid: process.Pid, value: Bool) -> atom.Atom

@external(erlang, "Elixir.Excansock", "recv_own_messages")
fn recv_own_messages_external(pid: process.Pid, value: Bool) -> atom.Atom

@external(erlang, "Elixir.Excansock", "set_filters")
fn set_filters_external(
  pid: process.Pid,
  filters: List(bridge.CanFilter),
) -> atom.Atom

@external(erlang, "Elixir.Excansock", "set_error_filter")
fn set_error_filter_external(pid: process.Pid, filter: Int) -> atom.Atom

// INTERNAL -----------------------------------------------------------------------

fn check_status(status: atom.Atom) -> Result(Nil, CanError) {
  case atom.to_string(status) {
    "ok" -> Ok(Nil)
    other -> Error(UnknownError(other))
  }
}

fn decode_result(raw: dynamic.Dynamic) -> Result(Nil, CanError) {
  let ok = atom.create("ok")

  let error_tuple_decoder = {
    use tag_dyn <- decode.subfield([0], decode.dynamic)
    use reason_dyn <- decode.subfield([1], decode.dynamic)

    let tag = atom.cast_from_dynamic(tag_dyn)
    let reason = atom.cast_from_dynamic(reason_dyn)

    case tag == atom.create("error"), reason == atom.create("ebound") {
      True, True -> decode.success(Error(InterfaceBound))
      _, _ -> decode.success(Error(UnknownError(atom.to_string(reason))))
    }
  }

  let success_atom_decoder = {
    use result_dyn <- decode.then(decode.dynamic)
    let result = atom.cast_from_dynamic(result_dyn)

    case result == ok {
      True -> decode.success(Ok(Nil))
      _ -> decode.success(Error(UnknownError(atom.to_string(result))))
    }
  }

  let decoder = decode.one_of(error_tuple_decoder, or: [success_atom_decoder])

  case decode.run(raw, decoder) {
    Ok(result) -> result
    _ -> Error(UnknownError("unparsable_return"))
  }
}

// PUBLIC -----------------------------------------------------------------------

pub opaque type CanSocket {
  CanSocket(pid: process.Pid)
}

pub type CanError {
  InterfaceBound
  UnknownError(String)
}

pub fn start() -> Result(CanSocket, CanError) {
  let #(status, pid) = start_link_external()
  case atom.to_string(status) {
    "ok" -> Ok(CanSocket(pid))
    other -> Error(UnknownError(other))
  }
}

pub fn open(socket: CanSocket, interface: String) -> Result(Nil, CanError) {
  let raw = open_external(socket.pid, interface, False)
  decode_result(raw)
}

pub fn close(socket: CanSocket) -> Result(Nil, CanError) {
  let status = close_external(socket.pid)
  check_status(status)
}

pub fn send(socket: CanSocket, frame: bridge.CanFrame) -> Result(Nil, CanError) {
  let status = send_external(socket.pid, frame)
  check_status(status)
}

pub fn set_loopback(socket: CanSocket, value: Bool) -> Result(Nil, CanError) {
  let status = set_loopback_external(socket.pid, value)
  check_status(status)
}

pub fn recv_own_messages(
  socket: CanSocket,
  value: Bool,
) -> Result(Nil, CanError) {
  let status = recv_own_messages_external(socket.pid, value)
  check_status(status)
}

pub fn set_filters(
  socket: CanSocket,
  filters: List(bridge.CanFilter),
) -> Result(Nil, CanError) {
  let status = set_filters_external(socket.pid, filters)
  check_status(status)
}

pub fn set_error_filter(socket: CanSocket, filter: Int) -> Result(Nil, CanError) {
  let status = set_error_filter_external(socket.pid, filter)
  check_status(status)
}

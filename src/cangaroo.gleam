import cangaroo/bridge
import cangaroo/errors
import cangaroo/excansock
import cangaroo/internal
import cangaroo/types
import gleam/erlang/atom
import gleam/erlang/process
import gleam/otp/actor
import gleam/result

fn start() -> Result(types.CanSocket, errors.CanError) {
  let #(status, pid) = excansock.start_link()

  case atom.to_string(status) {
    "ok" -> Ok(types.CanSocket(pid))
    other_msg -> Error(errors.StartLinkError(other_msg))
  }
}

fn open(
  socket: types.CanSocket,
  interface: String,
) -> Result(Nil, errors.CanError) {
  let raw = excansock.open(socket.pid, interface, False)
  internal.decode_result(raw)
}

pub fn start_link(interface: String) -> Result(types.CanClient, errors.CanError) {
  let user_frames = process.new_subject()

  let actor_result =
    {
      actor.new_with_initialiser(5000, fn(self_subject) {
        let can_tag = atom.create("can_data_frame")
        let selector =
          process.new_selector()
          |> process.select(self_subject)
          |> process.select_record(can_tag, 1, types.CanFrameReceived)

        use socket <- result.try(
          start() |> result.map_error(internal.error_to_string),
        )

        use _ <- result.try(
          open(socket, interface) |> result.map_error(internal.error_to_string),
        )

        let client = types.CanClient(socket: socket, subject: user_frames)

        actor.initialised(client)
        |> actor.selecting(selector)
        |> actor.returning(client)
        |> Ok
      })
    }
    |> actor.on_message(handle_message)
    |> actor.start()

  case actor_result {
    Ok(started) -> {
      Ok(types.CanClient(
        socket: started.data.socket,
        subject: started.data.subject,
      ))
    }
    Error(actor.InitFailed(reason)) -> Error(errors.UnknownError(reason))
    Error(_) -> Error(errors.UnknownError("Actor failed to start"))
  }
}

fn handle_message(
  client: types.CanClient,
  msg: types.CanMessage,
) -> actor.Next(types.CanClient, types.CanMessage) {
  case msg {
    types.CanFrameReceived(raw_frame) -> {
      let frame = bridge.unwrap_frame(raw_frame)
      let id = bridge.get_id(frame)
      let data = bridge.get_data(frame)
      let gleam_frame = types.CanFrame(id: id, data: data)
      process.send(client.subject, gleam_frame)
      actor.continue(client)
    }
    types.Shutdown -> actor.continue(client)
  }
}

pub fn close(socket: types.CanSocket) -> Result(Nil, errors.CanError) {
  let status = excansock.close(socket.pid)
  internal.check_status(status)
}

pub fn send(
  socket: types.CanSocket,
  frame: types.CanFrame,
) -> Result(Nil, errors.CanError) {
  let status = excansock.send(socket.pid, frame)
  internal.check_status(status)
}

pub fn set_loopback(
  socket: types.CanSocket,
  value: Bool,
) -> Result(Nil, errors.CanError) {
  let status = excansock.set_loopback(socket.pid, value)
  internal.check_status(status)
}

pub fn recv_own_messages(
  socket: types.CanSocket,
  value: Bool,
) -> Result(Nil, errors.CanError) {
  let status = excansock.recv_own_messages(socket.pid, value)
  internal.check_status(status)
}

pub fn set_filters(
  socket: types.CanSocket,
  filters: List(types.CanFilter),
) -> Result(Nil, errors.CanError) {
  let status = excansock.set_filters(socket.pid, filters)
  internal.check_status(status)
}

pub fn set_error_filter(
  socket: types.CanSocket,
  filter: Int,
) -> Result(Nil, errors.CanError) {
  let status = excansock.set_error_filter(socket.pid, filter)
  internal.check_status(status)
}

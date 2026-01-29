import gleam/dynamic
import gleam/erlang/process

pub type CanSocket {
  CanSocket(pid: process.Pid)
}

pub type CanClient {
  CanClient(socket: CanSocket, subject: process.Subject(CanFrame))
}

pub type CanMessage {
  CanFrameReceived(frame: dynamic.Dynamic)
  Shutdown
}

pub type CanFrame {
  CanFrame(id: Int, data: BitArray)
}

pub type CanFilter

pub type CanError {
  InterfaceBound
  StartLinkError(String)
  UnknownError(String)
}

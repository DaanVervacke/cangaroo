import cangaroo/types
import gleam/dynamic
import gleam/erlang/atom
import gleam/erlang/process

@external(erlang, "Elixir.Excansock", "start_link")
pub fn start_link() -> #(atom.Atom, process.Pid)

@external(erlang, "Elixir.Excansock", "open")
pub fn open(pid: process.Pid, interface: String, canfd: Bool) -> dynamic.Dynamic

@external(erlang, "Elixir.Excansock", "close")
pub fn close(pid: process.Pid) -> atom.Atom

@external(erlang, "Elixir.Excansock", "send")
pub fn send(pid: process.Pid, frame: types.CanFrame) -> atom.Atom

@external(erlang, "Elixir.Excansock", "set_loopback")
pub fn set_loopback(pid: process.Pid, value: Bool) -> atom.Atom

@external(erlang, "Elixir.Excansock", "recv_own_messages")
pub fn recv_own_messages(pid: process.Pid, value: Bool) -> atom.Atom

@external(erlang, "Elixir.Excansock", "set_filters")
pub fn set_filters(
  pid: process.Pid,
  filters: List(types.CanFilter),
) -> atom.Atom

@external(erlang, "Elixir.Excansock", "set_error_filter")
pub fn set_error_filter(pid: process.Pid, filter: Int) -> atom.Atom

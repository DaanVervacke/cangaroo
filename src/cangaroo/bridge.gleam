import cangaroo/types
import gleam/dynamic

@external(erlang, "bridge_ffi", "new_filter")
pub fn new_filter(id: Int, mask: Int) -> types.CanFilter

@external(erlang, "bridge_ffi", "new_frame")
pub fn new_frame(id: Int, data: BitArray) -> types.CanFrame

@external(erlang, "bridge_ffi", "get_id")
pub fn get_id(frame: dynamic.Dynamic) -> Int

@external(erlang, "bridge_ffi", "get_data")
pub fn get_data(frame: dynamic.Dynamic) -> BitArray

@external(erlang, "bridge_ffi", "unwrap_frame")
pub fn unwrap_frame(msg: dynamic.Dynamic) -> dynamic.Dynamic

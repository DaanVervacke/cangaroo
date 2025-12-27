pub type CanFilter

pub type CanFrame

@external(erlang, "bridge_ffi", "new_filter")
pub fn new_filter(id: Int, mask: Int) -> CanFilter

@external(erlang, "bridge_ffi", "new_frame")
pub fn new_frame(id: Int, data: BitArray) -> CanFrame

@external(erlang, "bridge_ffi", "get_id")
pub fn get_id(frame: CanFrame) -> Int

@external(erlang, "bridge_ffi", "get_data")
pub fn get_data(frame: CanFrame) -> BitArray

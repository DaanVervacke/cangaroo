-module(bridge_ffi).
-export([new_filter/2, new_frame/2, unwrap_frame/1, get_id/1, get_data/1, identity/1]).

%% Elixir: %CanFilter{can_id: id, can_mask: mask}
new_filter(Id, Mask) ->
    #{
        '__struct__' => 'Elixir.Excansock.CanFilter',
        can_id => Id,
        can_mask => Mask
    }.

%% Elixir: %CanFrame{id: id, data: data}
new_frame(Id, Data) ->
    #{
        '__struct__' => 'Elixir.Excansock.CanFrame',
        id => Id,
        data => Data
    }.

%% Extract the frame map from the {can_data_frame, Frame} tuple
unwrap_frame({can_data_frame, Frame}) ->
    Frame.

%% Extract the 'id' field from the CanFrame map/struct
get_id(#{id := Id}) ->
    Id.

%% Extract the 'data' field from the CanFrame map/struct
get_data(#{data := Data}) ->
    Data.

identity(X) -> X.

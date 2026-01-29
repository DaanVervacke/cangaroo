import cangaroo/errors
import gleam/dynamic
import gleam/dynamic/decode
import gleam/erlang/atom

pub fn error_to_string(err: errors.CanError) -> String {
  case err {
    errors.InterfaceBound -> "interface_bound"
    errors.StartLinkError(reason) -> reason
    errors.UnknownError(reason) -> reason
  }
}

pub fn check_status(status: atom.Atom) -> Result(Nil, errors.CanError) {
  case atom.to_string(status) {
    "ok" -> Ok(Nil)
    other -> Error(errors.UnknownError(other))
  }
}

pub fn decode_result(raw: dynamic.Dynamic) -> Result(Nil, errors.CanError) {
  let ok = atom.create("ok")

  let error_tuple_decoder = {
    use tag_dyn <- decode.subfield([0], decode.dynamic)
    use reason_dyn <- decode.subfield([1], decode.dynamic)

    let tag = atom.cast_from_dynamic(tag_dyn)
    let reason = atom.cast_from_dynamic(reason_dyn)

    case tag == atom.create("error"), reason == atom.create("ebound") {
      True, True -> decode.success(Error(errors.InterfaceBound))
      _, _ -> decode.success(Error(errors.UnknownError(atom.to_string(reason))))
    }
  }

  let success_atom_decoder = {
    use result_dyn <- decode.then(decode.dynamic)
    let result = atom.cast_from_dynamic(result_dyn)

    case result == ok {
      True -> decode.success(Ok(Nil))
      _ -> decode.success(Error(errors.UnknownError(atom.to_string(result))))
    }
  }

  let decoder = decode.one_of(error_tuple_decoder, or: [success_atom_decoder])

  case decode.run(raw, decoder) {
    Ok(result) -> result
    _ -> Error(errors.UnknownError("unparsable_return"))
  }
}

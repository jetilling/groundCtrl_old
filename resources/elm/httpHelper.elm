module HttpHelper exposing (..)

import Http
import Json.Decode exposing (Decoder, field, string, bool, int, map, map2)

type alias CreateResponse =
  { success : Bool
  , newItemId : Int
  }

createHeader : String -> String -> Http.Header
createHeader key value = 
  Http.header key value


postCreateResponseDecoder : Decoder CreateResponse
postCreateResponseDecoder =
  map2 CreateResponse
    (field "success" bool)
    (field "newItemId" int)


postResponseDecoder : Decoder Bool
postResponseDecoder =
  (field "success" bool)
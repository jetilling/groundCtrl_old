module State exposing (..)

import Types exposing (..)
import Json.Encode as Encode
import Json.Decode exposing (Decoder, field, string, bool)

import Http

init : Flags -> ( Model, Cmd Msg )
init flags =
  ( ( Model 
    flags.tabs 
    False 
    flags.workspaceId 
    flags.csrfToken
    False 
    False 
    emptyTab
    False
    False)
  , Cmd.none
  )

emptyTab : Tab
emptyTab =
  { id = "" 
  , url = ""
  , name = ""
  }

updateNewTab : String -> (String -> Tab -> Tab) -> Model -> ( Model, Cmd Msg )
updateNewTab newValue updateFunction model =
  let
    updatedNewTab =
      updateFunction newValue model.newTab
  in
    ( { model | newTab = updatedNewTab }, Cmd.none )

setTabName : String -> Tab -> Tab
setTabName newName tab =
  { tab | name = newName }


setTabUrl : String -> Tab -> Tab
setTabUrl newUrl tab =
  { tab | url = newUrl }

createTabCommand : Model -> Tab -> Cmd Msg
createTabCommand model tab =
  Http.request
    { url = "http://localhost:8080/home/workspaces/" ++ String.fromInt model.workspaceId ++ "/tab"
    , headers = [ createHeader "X-CSRF-TOKEN" model.csrfToken ]
    , body = Http.jsonBody (newTabEncoder tab)
    , method = "POST"
    , expect = Http.expectJson TabCreated postResponseDecoder
    , timeout = Nothing
    , tracker = Nothing
    }

updateTabCommand : Model -> Tab -> Cmd Msg
updateTabCommand model tab =
  Http.request
    { url = "http://localhost:8080/home/tabs/" ++ tab.id
    , headers = [ createHeader "X-CSRF-TOKEN" model.csrfToken ]
    , body = Http.jsonBody (newTabEncoder tab)
    , method = "PUT"
    , expect = Http.expectJson TabUpdated postResponseDecoder
    , timeout = Nothing
    , tracker = Nothing
    }

deleteTabCommand : Model -> Tab -> Cmd Msg
deleteTabCommand model tab =
  Http.request
    { url = "http://localhost:8080/home/tabs/" ++ tab.id
    , headers = [ createHeader "X-CSRF-TOKEN" model.csrfToken ]
    , body = Http.jsonBody (newTabEncoder tab)
    , method = "DELETE"
    , expect = Http.expectJson TabDeleted postResponseDecoder
    , timeout = Nothing
    , tracker = Nothing
    }

createHeader : String -> String -> Http.Header
createHeader key value = 
  Http.header key value

newTabEncoder : Tab -> Encode.Value
newTabEncoder tab =
  Encode.object
    [ ( "name", Encode.string tab.name )
    , ( "url", Encode.string tab.url )
    ]

postResponseDecoder : Decoder Bool
postResponseDecoder =
  (field "success" bool)

replaceTab : List Tab -> Tab -> List Tab
replaceTab tabs newTab =
  let
    replace tab =
      if tab.id == newTab.id then
        { tab | id = newTab.id, name = newTab.name, url = newTab.url }
      else
        tab
  in
    List.map replace tabs

deleteTab : List Tab -> Tab -> List Tab
deleteTab tabs newTab =
  let
    search tab =
      if tab.id == newTab.id then
        False
      else
        True
  in
    List.filter search tabs


handleTabCreated : Model -> ( Result Http.Error Bool ) -> ( Model, Cmd Msg )
handleTabCreated model result =
  case result of 
    Ok tab ->
      let 
        newTabList = 
          List.append model.tabs [model.newTab]
      in
        ( { model | tabs = newTabList, newTab = emptyTab, showAddTab = False }, Cmd.none )
    Err err ->
      ( { model | errorOccured = True }, Cmd.none)

handleTabUpdated : Model -> ( Result Http.Error Bool ) -> ( Model, Cmd Msg )
handleTabUpdated model result =
  case result of 
    Ok tab ->
      let 
        newTabList = 
          replaceTab model.tabs model.newTab
      in
        ( { model | tabs = newTabList, newTab = emptyTab, showAddTab = False }, Cmd.none )
    Err err ->
      ( { model | errorOccured = True }, Cmd.none)

handleTabDeleted : Model -> ( Result Http.Error Bool ) -> ( Model, Cmd Msg )
handleTabDeleted model result =
  case result of 
    Ok tab ->
      let 
        newTabList = 
          deleteTab model.tabs model.newTab
      in
        ( { model | tabs = newTabList, newTab = emptyTab }, Cmd.none )
    Err err ->
      ( { model | errorOccured = True }, Cmd.none)
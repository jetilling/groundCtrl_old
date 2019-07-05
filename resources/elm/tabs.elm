module Tabs exposing (..)

import Browser
import Html exposing (Html, button, div, text, p, label, input, h4, a)
import Html.Events exposing (onClick, onInput)
import Html.Attributes exposing (class, classList, type_, placeholder, value, href)
import Http
import Debug
import Json.Encode as Encode
import Json.Decode exposing (Decoder, field, string, bool, map3)


main : Program Flags Model Msg
main =
  Browser.element { 
    init = init
    , view = view
    , update = update
    , subscriptions = subscriptions
  }


-- MODEL

type alias Flags =
  { tabs : List Tab
  , workspaceId : Int
  , csrfToken : String 
  }

type alias Model = 
  { tabs : List Tab
  , showAddTab : Bool
  , workspaceId : Int
  , csrfToken : String
  , errorOccured : Bool
  , newTab : Tab
  }

type alias Tab =
  { id : String
  , url : String
  , name : String
  }

emptyTab : Tab
emptyTab =
  { id = "" 
  , url = ""
  , name = ""
  }

init : Flags -> ( Model, Cmd Msg )
init flags =
  ( (Model flags.tabs False flags.workspaceId flags.csrfToken False emptyTab)
  , Cmd.none
  )

-- UPDATE

type Msg
  = ShowAddTab 
  | HideAddTab 
  | CreateNewTab
  | TabCreated (Result Http.Error Bool )
  | Url String
  | Name String

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    ShowAddTab ->
      ( { model | showAddTab = True }, Cmd.none)

    HideAddTab -> 
      ( { model | showAddTab = False }, Cmd.none )

    Url url ->
      updateNewTab url setTabUrl model

    Name name ->
      updateNewTab name setTabName model

    CreateNewTab ->
      ( model, createTabCommand model model.newTab )
    
    TabCreated result ->
      case result of 
        Ok tab ->
          let 
            newTabList = 
              List.append model.tabs [model.newTab]
          in
            ( { model | tabs = newTabList, newTab = emptyTab, showAddTab = False }, Cmd.none )
        Err err ->
          ( { model | errorOccured = True }, Cmd.none)


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
    createPostRequest model tab



createPostRequest : Model -> Tab -> Cmd Msg
createPostRequest model tab =
    Http.request
        { url = "http://localhost:8080/home/workspaces/" ++ String.fromInt model.workspaceId ++ "/tab"
        , headers = [ createHeader "X-CSRF-TOKEN" model.csrfToken ]
        , body = Http.jsonBody (newTabEncoder tab)
        , method = "POST"
        , expect = Http.expectJson TabCreated postResponseDecoder
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

-- VIEW

view : Model -> Html Msg
view model =
  div [class "content"] 
    [ div [class "columns"]
      [ div [class "column"] [ p [class "title"] [text "Tabs"] ]
      , div [class "column"] 
        [ button [ classList
          [ ("button", True)
          , ("is-small", True)
          ]
          , onClick ShowAddTab ] [ text "Add Tab" ]
        ]
      ]
    , p [ class "subtitle" ] [ text "Manage workspace specific browser tabs"]
    , p [ classList 
          [ ("error-msg", True)
          , ("display-block", model.errorOccured)
          , ("no-display", not model.errorOccured)
          ] 
        ] [ text "An error occurred while trying to add a new tab" ]
    , div [ classList 
        [ ("box", True)
        , ("display-block", model.showAddTab)
        , ("no-display", not model.showAddTab)
        ] 
      ] 
      [ h4 [ class "title" ] [ text "New Tab" ]
      , viewFormField "Url" "url" model.newTab.url Url
      , viewFormField "Name" "name" model.newTab.name Name
      , div [ class "field" ] 
        [ div [ class "control" ] 
          [ button [ classList
              [ ("button", True)
              , ("is-link", True) 
              ]
              , onClick CreateNewTab ] [ text "Add Tab" ]
            , button [ classList
              [ ("button", True)
              , ("is-danger", True) 
              ]
              , onClick HideAddTab ] [ text "Cancel" ]
          ]
        ]
      ]
    , div [] ( renderTabs model.tabs )
    ]

viewFormField : String -> String -> String -> (String -> msg) -> Html msg
viewFormField labelText name value toMsg  =
  div [ class "field" ] 
    [ label [ class "label" ] [ text labelText ]
    , div [ class "control" ] [ viewInput value toMsg ]
  ]

viewInput : String -> (String -> msg) -> Html msg
viewInput v toMsg =
  input [ class "input", type_ "text", placeholder "", value v, onInput toMsg ] []

renderTabs : List Tab -> List (Html msg)
renderTabs tabs =
  List.map renderTab tabs

renderTab : Tab -> Html msg
renderTab tab =
  div [ class "tab-link-container"] 
  [  a [ href tab.url ] [ text tab.name ]
  ]

-- SUBSCRIPTIONS

subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.none

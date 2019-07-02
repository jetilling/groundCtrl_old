module Tabs exposing (..)

import Browser
import Html exposing (Html, button, div, text, p, label, input, h4)
import Html.Events exposing (onClick, onInput)
import Html.Attributes exposing (class, classList, type_, placeholder, value)


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
  , workspaceId : Int }

type alias Model = 
  { tabs : List Tab
  , showAddTab : Bool
  , workspaceId : Int
  , newTabName : String
  , newTabUrl : String
  }

type alias Tab =
  { url : String
  , name : String
  }

-- emptyTab : Tab
-- emptyTab =
--   { url = ""
--   , name = ""
--   }

init : Flags -> ( Model, Cmd Msg )
init flags =
  ( (Model flags.tabs False flags.workspaceId "" "")
  , Cmd.none
  )

-- UPDATE

type Msg
  = ShowAddTab 
  | HideAddTab 
  | SaveNewTab
  | Url String
  | Name String

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    ShowAddTab ->
      ( { model | showAddTab = True }
      , Cmd.none
      )

    HideAddTab -> 
      ( { model | showAddTab = False }
      , Cmd.none
      )

    Url url ->
      ( { model | newTabUrl = url}
      , Cmd.none )

    Name name ->
      ( { model | newTabName = name }
      , Cmd.none )
    
    SaveNewTab ->
      ( model, Cmd.none )
      

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
    , div [ classList 
        [ ("box", True)
        , ("display-block", model.showAddTab)
        , ("no-display", not model.showAddTab)
        ] 
      ] 
      [ h4 [ class "title" ] [ text "New Tab" ]
      , viewFormField "Url" "url" model.newTabUrl Url
      , viewFormField "Name" "name" model.newTabName Name
      , div [ class "field" ] 
        [ div [ class "control" ] 
          [ button [ classList
              [ ("button", True)
              , ("is-link", True) 
              ]
              , onClick SaveNewTab ] [ text "Add Tab" ]
            , button [ classList
              [ ("button", True)
              , ("is-danger", True) 
              ]
              , onClick HideAddTab ] [ text "Cancel" ]
          ]
        ]
      ]
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

-- SUBSCRIPTIONS

subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.none

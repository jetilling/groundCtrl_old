port module Tabs exposing (..)

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

port openTabs : List Tab -> Cmd msg

port closeTabs : List Tab -> Cmd msg

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
  , tabsAreOpen : Bool
  , newTab : Tab
  , editTabMode : Bool
  , deleteTabMode : Bool
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

-- UPDATE

type Msg
  = ShowAddTab 
  | HideAddTab 
  | CreateNewTab
  | EditTab
  | OpenTabs
  | CloseTabs
  | TabCreated ( Result Http.Error Bool )
  | TabUpdated ( Result Http.Error Bool )
  | TabDeleted ( Result Http.Error Bool )
  | Url String
  | Name String
  | EnterEditTabMode Tab
  | DeleteTab Tab

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    ShowAddTab ->
      ( { model | showAddTab = True }, Cmd.none)

    HideAddTab -> 
      ( { model | showAddTab = False, newTab = emptyTab, editTabMode = False }, Cmd.none )

    Url url ->
      updateNewTab url setTabUrl model

    Name name ->
      updateNewTab name setTabName model

    OpenTabs ->
      ( { model | tabsAreOpen = True }, openTabs model.tabs )

    CloseTabs ->
      ( { model | tabsAreOpen = False }, closeTabs model.tabs )
    
    EnterEditTabMode tab ->
      ( { model | newTab = tab, showAddTab = True, editTabMode = True }, Cmd.none )
    
    EditTab ->
      ( model, updateTabCommand model model.newTab )

    DeleteTab tab ->
      ( { model | newTab = tab }, deleteTabCommand model tab )

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

    TabUpdated result ->
      case result of 
        Ok tab ->
          let 
            newTabList = 
              replaceTab model.tabs model.newTab
          in
            ( { model | tabs = newTabList, newTab = emptyTab, showAddTab = False }, Cmd.none )
        Err err ->
          ( { model | errorOccured = True }, Cmd.none)

    TabDeleted result ->
      case result of 
        Ok tab ->
          let 
            newTabList = 
              deleteTab model.tabs model.newTab
          in
            ( { model | tabs = newTabList, newTab = emptyTab }, Cmd.none )
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

-- VIEW

view : Model -> Html Msg
view model =
  div [class "content"] 
    [ div [class "columns"]
      [ div [class "column"] [ p [class "title"] [text "Tabs"] ]
      , div [class "column"] 
        [ div [class "columns"] 
          [ if model.tabsAreOpen then
             div [class "column"] 
              [ button [ classList
                [ ("button", True)
                , ("is-small", True) 
                ]
                , onClick CloseTabs ] [ text "Close Tabs"]
              ]
            else
              div [class "column"] 
              [ button [ classList
                [ ("button", True)
                , ("is-small", True) 
                ]
                ,onClick OpenTabs ] [ text "Open Tabs"]
              ]
          , div [class "column"]
            [ button [ classList
              [ ("button", True)
              , ("is-small", True)
              ]
              , onClick ShowAddTab ] [ text "Add Tab" ]
            ]
          ]
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
        [ div [ class "control", class "display-flex" ] 
          [ if model.editTabMode then 
              button [ classList
                [ ("button", True)
                , ("is-link", True) 
                ]
                , onClick EditTab ] [ text "Edit Tab" ]
            else
              button [ classList
                [ ("button", True)
                , ("is-link", True) 
                ]
                , onClick CreateNewTab ] [ text "Add Tab" ]
            , button [ class "cancel-form-btn", onClick HideAddTab ] [ text "Cancel" ]
          ]
        ]
      ]
    , div [ classList [("tile", True), ("is-ancestor", True)]] 
      [ div [ classList 
          [ ("tile", True)
          , ("is-12", True)
          , ("is-vertical", True)
          , ("is-parent", True)
          ]
        ] ( renderTabs model.tabs )
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

renderTabs : List Tab -> List (Html Msg)
renderTabs tabs =
  List.map renderTab tabs

renderTab : Tab -> Html Msg
renderTab tab =
  div [ classList 
      [ ("tile", True)
      , ("is-child", True)
      , ("box", True)
      ]
    ] 
  [ div [ class "columns", class "is-4" ] 
    [ div [ class "column" ] [a [ href tab.url, class "link" ] [ text tab.name ] ]
    , div [ class "column", class "is-two-fifths" ]
      [ div [ class "columns" ] 
        [ div [ class "column", class "center-items"] 
          [ button [ classList 
              [ ("button", True)
              , ("is-link", True)
              , ("is-small", True)
              , ("is-outlined", True)
              ]
              , onClick ( EnterEditTabMode tab )
            ] [ text "Edit" ]
          ]
        , div [ class "column", class "center-items" ] 
          [ button [ classList 
              [ ("button", True)
              , ("is-danger", True)
              , ("is-small", True)
              , ("is-outlined", True)
              ]
              , onClick ( DeleteTab tab )
            ] [ text "Delete"]
          ]
        ]
      ]
    ]
  ]

-- SUBSCRIPTIONS

subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.none

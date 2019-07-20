port module Main exposing (..)

import Browser
import Http
import Json.Encode as Encode
import Json.Decode exposing (Decoder, field, string, bool, int, map, map2)
import Html exposing (Html, Attribute, button, div, text, p, label, input, h4, a, ul, li, span)
import Html.Events exposing (onClick, on, keyCode, onInput)
import Html.Attributes exposing (class, classList, type_, placeholder, value, href, style)
import Debug

import Converter exposing (..)

-- MAIN

main : Program Flags Model Msg
main =
  Browser.element { 
    init = init
    , view = view
    , update = update
    , subscriptions = subscriptions
  }

port openBrowserTabs : List Tab -> Cmd msg

port closeBrowserTabs : List Tab -> Cmd msg

-- MODEL

type alias Flags =
  { tabs : List Tab
  , workspaceId : Int
  , workspaceName : String
  , workspacePrimaryColor : String
  , csrfToken : String 
  }

type alias Model = 
  { currentView : CurrentView
  , workspaceId : Int
  , workspaceName : String
  , workspacePrimaryColor : String
  , csrfToken : String
  , commandString : String
  , errorOccured : Bool
  , tabs : List Tab
  , newTab : Tab
  , browserTabsAreOpen : Bool
  , editTabMode : Bool
  }

type CurrentView
  = Tabs
  | Notes
  | Tasks
  | Help

type alias Tab =
  { id : Int
  , url : String
  , name : String
  }

type alias CreateResponse =
  { success : Bool
  , newItemId : Int
  }

emptyTab : Tab
emptyTab =
  { id = 0 
  , url = ""
  , name = ""
  }

init : Flags -> (Model, Cmd Msg)
init flags =
  ( ( Model
    Help
    flags.workspaceId
    flags.workspaceName
    flags.workspacePrimaryColor
    flags.csrfToken
    ""
    False
    flags.tabs
    emptyTab
    False
    False)
  , Cmd.none
  )


-- UPDATE


type Msg
  = OpenBrowserTabs
  | CloseBrowserTabs
  | UpdateCommandString String
  | KeyDown Int
  | EnterEditTabMode Tab
  | EditTab
  | DeleteTab Tab
  | CreateNewTab
  | TabCreated ( Result Http.Error CreateResponse )
  | TabUpdated ( Result Http.Error Bool )
  | TabDeleted ( Result Http.Error Bool )


update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of

    OpenBrowserTabs ->
      ( { model | browserTabsAreOpen = True }, openBrowserTabs model.tabs )

    CloseBrowserTabs ->
      ( { model | browserTabsAreOpen = False }, closeBrowserTabs model.tabs )

    UpdateCommandString commandString ->
      ( { model | commandString = commandString }, Cmd.none)

    KeyDown key ->
      if key == 13 then
        handleCommand model
      else
        (model, Cmd.none)

    EnterEditTabMode tab ->
      ( { model | newTab = tab, editTabMode = True }, Cmd.none )
    
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
            addTabId currentTab tabResponse = 
              { currentTab | id = tabResponse.newItemId }

            newTab = 
              addTabId model.newTab tab

            newTabList = 
              List.append model.tabs [newTab]
          in
            ( { model | tabs = newTabList, newTab = emptyTab }, Cmd.none )
        Err err ->
          ( { model | errorOccured = True }, Cmd.none)

    TabUpdated result ->
      case result of 
        Ok tab ->
          let 
            newTabList = 
              replaceTab model.tabs model.newTab
          in
            ( { model | tabs = newTabList, newTab = emptyTab }, Cmd.none )
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


handleCommand : Model -> ( Model, Cmd Msg )
handleCommand model =
  let
      lowerCaseCmd =
        String.toLower model.commandString

      commandRecord =
        Converter.convertToAST model.commandString

  in
    if commandRecord.function == "view" then handleViewCommand model commandRecord
    else if commandRecord.function == "open" then handleOpenCommand model commandRecord
    else if commandRecord.function == "close" then handleCloseCommand model
    else if commandRecord.function == "create" then handleCreateCommand model commandRecord

    -- else if String.startsWith "edit" lowerCaseCmd then

    -- else if String.startsWith "delete" lowerCaseCmd then

    -- else if String.startsWith "complete" lowerCaseCmd then

    else
      ( model, Cmd.none )


handleViewCommand : Model -> Converter.CommandRecord -> ( Model, Cmd Msg )
handleViewCommand model commandRecord =
  if String.contains "tab" commandRecord.view then ( { model | currentView = Tabs, commandString = "" }, Cmd.none )
  else if String.contains "task" commandRecord.view then ( { model | currentView = Tasks, commandString = "" }, Cmd.none )
  else if String.contains "note" commandRecord.view then ( { model | currentView = Notes, commandString = "" }, Cmd.none )
  else ( model, Cmd.none )


handleOpenCommand : Model -> Converter.CommandRecord -> ( Model, Cmd Msg )
handleOpenCommand model commandRecord =
  if String.contains "tab" commandRecord.view then ( { model | browserTabsAreOpen = True, commandString = "" }, openBrowserTabs model.tabs )
  else ( model, Cmd.none )


handleCloseCommand : Model -> ( Model, Cmd Msg )
handleCloseCommand model =
  if model.browserTabsAreOpen then ( { model | browserTabsAreOpen = False, commandString = "" }, closeBrowserTabs model.tabs )
  else ( model, Cmd.none )


handleCreateCommand : Model -> Converter.CommandRecord -> ( Model, Cmd Msg )
handleCreateCommand model commandRecord =
  if String.contains "tab" commandRecord.view then handleCreateTab model commandRecord.arguments
  else if String.contains "task" commandRecord.view then ( { model | currentView = Tasks, commandString = "" }, Cmd.none )
  else if String.contains "note" commandRecord.view then ( { model | currentView = Notes, commandString = "" }, Cmd.none )
  else ( model, Cmd.none )


-- TASKS UPDATE FUNCTIONS

-- NOTES UPDATE FUNCTIONS

-- TABS UPDATE FUNCTIONS


handleCreateTab : Model -> List String -> ( Model, Cmd Msg )
handleCreateTab model valuesForCreate =
  let
      name =
        case List.head valuesForCreate of 
          Just extractedName ->
            String.trim extractedName 
          Nothing ->
           ""

      url =
        case List.head (List.drop 1 valuesForCreate) of 
          Just extractedUrl ->
            String.trim extractedUrl
          Nothing ->
           ""
  in
    updateNewTab model url name model.newTab


updateNewTab : Model -> String -> String -> Tab -> ( Model, Cmd Msg )
updateNewTab model newUrl newName tab =
  let
    updatedNewTab =
      { tab | name = newName, url = newUrl }
  in
    ( { model | newTab = updatedNewTab, commandString = "" }, createTabCommand model updatedNewTab )


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
    , expect = Http.expectJson TabCreated postCreateResponseDecoder
    , timeout = Nothing
    , tracker = Nothing
    }


updateTabCommand : Model -> Tab -> Cmd Msg
updateTabCommand model tab =
  Http.request
    { url = "http://localhost:8080/home/tabs/" ++ String.fromInt tab.id
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
    { url = "http://localhost:8080/home/tabs/" ++ String.fromInt tab.id
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


postCreateResponseDecoder : Decoder CreateResponse
postCreateResponseDecoder =
  map2 CreateResponse
    (field "success" bool)
    (field "newItemId" int)


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


onKeyDown : (Int -> msg) -> Attribute msg
onKeyDown tagger =
  on "keydown" (map tagger keyCode)


-- VIEW


view : Model -> Html Msg
view model =
  div 
    [ class "hero"
    , class "is-fullheight"
    , class "is-medium"
    , class "dark"
    , class "is-bold"
    , class "notification"
    , class "workspace-border"
    , style "border-color" model.workspacePrimaryColor
    ] 
    [ div [ class "content" ] 
      [ renderCommandLineInput model 
      , renderCommandLineResponse model ]
    ]

renderCommandLineInput : Model -> Html Msg
renderCommandLineInput model =
  div [ class "columns" ] 
  [ div [ class "column", class "is-one-quarter", class "center-vetically" ] [ p [ class "title" ] [ text model.workspaceName ] ]
  , div [ class "column" ] 
    [ div [ class "control", class "is-large" ]
      [ input [ class "input", class "is-large", type_ "text", value model.commandString, onInput UpdateCommandString, onKeyDown KeyDown ] []
      ]
    ]
  ]


renderCommandLineResponse : Model -> Html Msg
renderCommandLineResponse model =
  case model.currentView of
    Tabs ->
      div [ ] [ renderTabsList model ]
    Tasks ->
      div [ class "title" ] [ text "tasks" ]
    Notes ->
      div [ class "title" ] [ text "notes" ]
    Help ->
      div [ class "title" ] [ text "help" ]


-- TASKS VIEW RENDER FUNCTIONS


-- NOTES VIEW RENDER FUNCTIONS


-- TABS VIEW RENDER FUNCTIONS


renderTabsList : Model -> Html Msg
renderTabsList model =
  div [class "content"] 
    [ div [ class "columns", class "is-multiline" ] 
      ( renderTabs model.tabs ) 
    ]


renderTabs : List Tab -> List (Html Msg)
renderTabs tabs =
  List.map renderTab tabs


renderTab : Tab -> Html Msg
renderTab tab =
  div [ class "column", class "is-one-quarter"]
  [ div [class "box", class "set-box-height" ]
    [div [ class "columns", class "is-4" ] 
      [ div [ class "column", class "is-three-fifths" ] [a [ href tab.url, class "link" ] [ text tab.name ] ]
      , div [ class "column", class "is-two-fifths" ]
        [ div [ class "columns" ] 
          [ div [ class "column", class "center-items"] 
            [ button 
              [ class "button"
              , class "is-link"
              , class "is-small"
              , class "is-outlined"
              , onClick ( EnterEditTabMode tab )
              ] [ text "Edit" ]
            ]
          , div [ class "column", class "center-items" ] 
            [ button 
              [ class "delete"
              , class "is-medium"
              , class "is-red"
              , onClick ( DeleteTab tab )
              ] []
            ]
          ]
        ]
      ]
    ]
  ]

-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.none
port module Main exposing (..)

import Browser
import Http
import Json.Encode as Encode
import Json.Decode exposing (Decoder, field, string, bool, int, map, map2)
import Html exposing (Html, Attribute, button, div, text, p, label, input, h4, a, ul, li, span, section)
import Html.Events exposing (onClick, on, keyCode, onInput)
import Html.Attributes exposing (class, classList, type_, placeholder, value, href, style, autofocus)
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
  , highPriorityTasks : List Task
  , moderatePriorityTasks : List Task
  , lowPriorityTasks : List Task
  , generalPriorityTasks : List Task
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
  , highPriorityTasks : List Task
  , moderatePriorityTasks : List Task
  , lowPriorityTasks : List Task
  , generalPriorityTasks : List Task
  , newTask : Task
  , showTaskId : Bool
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
  , uiid : String
  }

type alias Task = 
  { id : Int
  , name : String
  , completed : Bool
  , priority : String
  , uiid : String
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
  , uiid = ""
  }

emptyTask : Task
emptyTask =
  { id = 0 
  , name = ""
  , completed = False
  , priority = ""
  , uiid = ""
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
    flags.highPriorityTasks
    flags.moderatePriorityTasks
    flags.lowPriorityTasks
    flags.generalPriorityTasks
    emptyTask
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
  | DeleteTab Tab
  | TabCreated ( Result Http.Error CreateResponse )
  | TabUpdated ( Result Http.Error Bool )
  | TabDeleted ( Result Http.Error Bool )
  | TaskCreated ( Result Http.Error CreateResponse )


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
      let 
        commandString =
          "edit tab " ++ tab.uiid ++ " [" ++ tab.name ++ ", " ++ tab.url ++ "]"
      in
        ( { model | newTab = tab, commandString = commandString }, Cmd.none )

    DeleteTab tab ->
      ( { model | newTab = tab }, deleteTabCommand model tab )
    
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

    TaskCreated result ->
      case result of 
        Ok task ->
          let 
            addTaskId currentTask taskResponse = 
              { currentTask | id = taskResponse.newItemId }

            newTask = 
              addTaskId model.newTask task

            highTaskList = 
              if newTask.priority == "high" then List.append model.highPriorityTasks [newTask]
              else model.highPriorityTasks
            
            moderateTaskList =
              if newTask.priority == "moderate" then List.append model.moderatePriorityTasks [newTask]
              else model.moderatePriorityTasks

            lowTaskList =
              if newTask.priority == "low" then List.append model.lowPriorityTasks [newTask]
              else model.lowPriorityTasks

            generalTaskList =
              if newTask.priority == "general" then List.append model.generalPriorityTasks [newTask]
              else model.generalPriorityTasks
              
          in
            ( { model | highPriorityTasks = highTaskList, 
                        moderatePriorityTasks = moderateTaskList, 
                        lowPriorityTasks = lowTaskList, 
                        generalPriorityTasks = generalTaskList, newTask = emptyTask }, Cmd.none )
        Err err ->
          ( { model | errorOccured = True }, Cmd.none)


handleCommand : Model -> ( Model, Cmd Msg )
handleCommand model =
  let
      lowerCaseCmd =
        String.toLower model.commandString

      commandRecord =
        Converter.convertToRecord model.commandString

  in
    if commandRecord.function == "view" then handleViewCommand model commandRecord
    else if commandRecord.function == "open" then handleOpenCommand model commandRecord
    else if commandRecord.function == "close" then handleCloseCommand model
    else if commandRecord.function == "create" then handleCreateCommand model commandRecord
    else if commandRecord.function == "edit" then handleEditCommand model commandRecord

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
  else if String.contains "task" commandRecord.view then handleCreateTask model commandRecord.arguments
  else if String.contains "note" commandRecord.view then ( { model | currentView = Notes, commandString = "" }, Cmd.none )
  else ( model, Cmd.none )


handleEditCommand : Model -> Converter.CommandRecord -> ( Model, Cmd Msg)
handleEditCommand model commandRecord = 
  if String.contains "tab" commandRecord.view then handleEditTab model commandRecord
  else if String.contains "task" commandRecord.view then ( { model | currentView = Tasks, commandString = "" }, Cmd.none )
  else if String.contains "note" commandRecord.view then ( { model | currentView = Notes, commandString = "" }, Cmd.none )
  else ( model, Cmd.none )


-- TASKS UPDATE FUNCTIONS


handleCreateTask : Model -> List String -> ( Model, Cmd Msg )
handleCreateTask model valuesForCreate = 
  let
    name = 
      parseFirstArgument valuesForCreate

    priority =
      parseSecondArgument valuesForCreate
  in
    updateNewTask model priority name


updateNewTask : Model -> String -> String -> ( Model, Cmd Msg )
updateNewTask model priority name = 
  let
    updatedNewTask =
      { emptyTask | name = name, priority = priority }
  in
    ( { model | newTask = updatedNewTask, commandString = "" }, createTaskCommand model updatedNewTask )


createTaskCommand : Model -> Task -> Cmd Msg
createTaskCommand model task =
  Http.request
    { url = "http://localhost:8080/home/workspaces/" ++ String.fromInt model.workspaceId ++ "/task"
    , headers = [ createHeader "X-CSRF-TOKEN" model.csrfToken ]
    , body = Http.jsonBody (newTaskEncoder task)
    , method = "POST"
    , expect = Http.expectJson TaskCreated postCreateResponseDecoder
    , timeout = Nothing
    , tracker = Nothing
    }


newTaskEncoder : Task -> Encode.Value
newTaskEncoder task =
  Encode.object
    [ ( "name", Encode.string task.name )
    , ( "priority", Encode.string task.priority )
    ]


-- NOTES UPDATE FUNCTIONS

-- TABS UPDATE FUNCTIONS


handleCreateTab : Model -> List String -> ( Model, Cmd Msg )
handleCreateTab model valuesForCreate =
  let
    name = 
      parseFirstArgument valuesForCreate

    url =
      parseSecondArgument valuesForCreate
  in
    updateNewTab model url name model.newTab


handleEditTab : Model -> Converter.CommandRecord -> ( Model, Cmd Msg )
handleEditTab model commandRecord = 
  let

    matchingTab =
      let
        findTabIdMatch tab = 
          if tab.uiid == commandRecord.itemId then True
          else False
      in 
        case List.head (List.filter findTabIdMatch model.tabs) of
          Just extractedTab ->
            extractedTab
          Nothing -> 
            emptyTab

    name = 
      parseFirstArgument commandRecord.arguments

    url = 
      parseSecondArgument commandRecord.arguments

    updatedTab =
      { id = matchingTab.id, name = name, url = url, uiid = commandRecord.itemId }
  in
    ( { model | newTab = updatedTab, commandString = "" }, updateTabCommand model updatedTab )

parseFirstArgument : List String -> String
parseFirstArgument argumentList =
  case List.head argumentList of 
    Just extractedArg ->
      String.trim extractedArg 
    Nothing ->
      ""


parseSecondArgument : List String -> String
parseSecondArgument argumentList =
  case List.head (List.drop 1 argumentList) of 
    Just extractedArg ->
      String.trim extractedArg
    Nothing ->
      ""


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
      [ input [ class "input", class "is-large", type_ "text", value model.commandString, onInput UpdateCommandString, onKeyDown KeyDown, autofocus True ] []
      ]
    ]
  ]


renderCommandLineResponse : Model -> Html Msg
renderCommandLineResponse model =
  case model.currentView of
    Tabs ->
      div [ ] [ renderTabsList model ]
    Tasks ->
      div [ ] [ renderTasksList model ]
    Notes ->
      div [ class "title" ] [ text "notes" ]
    Help ->
      div [ class "title" ] [ text "help" ]


-- TASKS VIEW RENDER FUNCTIONS


renderTasksList : Model -> Html Msg
renderTasksList model = 
  div [class "content"] 
  [ div [ class "columns" ] 
    [ div [ class "column", class "is-three-quarters" ] 
      [ renderHighPriorityTasks model
      , renderModeratePriorityTasks model
      , renderLowPriorityTasks model
      , renderGeneralTasks model
      ]
    , div [ class "column", class "is-one-quarter" ] 
      [ section [ class "section" ] 
        [ h4 [ class "title" ] [text "Completed" ]
        ]
      ]
    ]
  ]


renderHighPriorityTasks : Model -> Html Msg
renderHighPriorityTasks model =
  section [ class "section" ] 
  [ h4 [ class "title", class "red-text" ] [text "High Priority"]
  , div [ class "red-left-border" ]
    ( List.map renderTask model.highPriorityTasks )
  ]


renderModeratePriorityTasks : Model -> Html Msg
renderModeratePriorityTasks model =
  section [ class "section" ] 
  [ h4 [ class "title", class "orange-text" ] [text "Moderate Priority" ]
  , div [ class "orange-left-border" ]
    ( List.map renderTask model.moderatePriorityTasks )
  ]


renderLowPriorityTasks : Model -> Html Msg
renderLowPriorityTasks model =
  section [ class "section" ] 
  [ h4 [ class "title", class "green-text" ] [text "Low Priority" ]
  , div [ class "green-left-border" ]
    ( List.map renderTask model.lowPriorityTasks )
  ]


renderGeneralTasks : Model -> Html Msg
renderGeneralTasks model =
  section [ class "section" ] 
  [ h4 [ class "title", class "blue-text" ] [text "General Tasks" ]
  , div [ class "blue-left-border" ]
    ( List.map renderTask model.generalPriorityTasks )
  ]


renderTask : Task -> Html Msg
renderTask task = 
  div [ class "column" ]
  [ div [ class "columns" ] 
    [ div [ class "column", class "is-full", class "task-container" ]
      [ div [ class "strike-through-on-hover" ] 
        [ div [ class "task-check-box" ] []
        , div [ class "task-item"] [ text task.name ]
        ]
      , button [ class "button", class "is-small", class "is-outlined", class "edit-task-button", class "task-item"] [ text "Edit" ]
      , div [ class "task-item", class "tag" ] [ text ("id: " ++ task.uiid) ]
      ]
    ]
  ]

-- NOTES VIEW RENDER FUNCTIONS


-- TABS VIEW RENDER FUNCTIONS


renderTabsList : Model -> Html Msg
renderTabsList model =
  div [class "content"] 
    [ div [ class "columns", class "is-multiline" ] 
      ( List.map renderTab model.tabs ) 
    ]


renderTab : Tab -> Html Msg
renderTab tab =
  div [ class "column", class "is-one-third"]
  [ div [class "box", class "set-box-height" ]
    [div [ class "columns", class "is-4" ] 
      [ div [ class "column", class "is-one-fifth" ] [ text tab.uiid ]
      , div [ class "column", class "is-two-fifths" ] [a [ href tab.url, class "link" ] [ text tab.name ] ]
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
port module Main exposing (..)

import Browser
import Http
import Json.Encode as Encode
import Json.Decode exposing (Decoder, field, string, bool, int, map, map2)
import Html exposing (Html, Attribute, button, div, text, p, label, input, h4, a, ul, li, span, section)
import Html.Events exposing (onClick, on, keyCode, onInput)
import Html.Attributes exposing (class, classList, type_, placeholder, value, href, style, autofocus)
import Debug

import Converter
import Utilities
import Tabs
import Tasks
import HttpHelper as HH

-- MAIN

main : Program Flags Model Msg
main =
  Browser.element { 
    init = init
    , view = view
    , update = update
    , subscriptions = subscriptions
  }

port openBrowserTabs : List Tabs.Tab -> Cmd msg

port closeBrowserTabs : List Tabs.Tab -> Cmd msg

-- MODEL

type alias Flags =
  { tabs : List Tabs.Tab
  , highPriorityTasks : List Tasks.Task
  , moderatePriorityTasks : List Tasks.Task
  , lowPriorityTasks : List Tasks.Task
  , generalPriorityTasks : List Tasks.Task
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
  , tabs : List Tabs.Tab
  , newTab : Tabs.Tab
  , browserTabsAreOpen : Bool
  , highPriorityTasks : List Tasks.Task
  , moderatePriorityTasks : List Tasks.Task
  , lowPriorityTasks : List Tasks.Task
  , generalPriorityTasks : List Tasks.Task
  , newTask : Tasks.Task
  , showTaskId : Bool
  }

type CurrentView
  = Tabs
  | Notes
  | Tasks
  | Help


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
    Tabs.emptyTab
    False
    flags.highPriorityTasks
    flags.moderatePriorityTasks
    flags.lowPriorityTasks
    flags.generalPriorityTasks
    Tasks.emptyTask
    False)
  , Cmd.none
  )


-- UPDATE


type Msg
  = OpenBrowserTabs
  | CloseBrowserTabs
  | UpdateCommandString String
  | KeyDown Int
  | EnterEditTabMode Tabs.Tab
  | EnterEditTaskMode Tasks.Task
  | DeleteTab Tabs.Tab
  | TabCreated ( Result Http.Error HH.CreateResponse )
  | TabUpdated ( Result Http.Error Bool )
  | TabDeleted ( Result Http.Error Bool )
  | TaskCreated ( Result Http.Error HH.CreateResponse )
  | TaskUpdated ( Result Http.Error Bool )


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

    EnterEditTaskMode task ->
      let
        commandString =
          "edit task " ++ task.uiid ++ " [" ++ task.name ++ ", " ++ task.priority ++ "]"
      in
        ( { model | newTask = task, commandString = commandString }, Cmd.none )
      

    DeleteTab tab ->
      ( { model | newTab = tab }, deleteTabCommand model tab )
    
    TabCreated result ->
      case result of 
        Ok tab ->
          let 
            addTabId currentTab tabResponse = 
              { currentTab | id = tabResponse.newItemId, uiid = String.fromInt ((List.length model.tabs) + 1) }

            newTab = 
              addTabId model.newTab tab

            newTabList = 
              List.append model.tabs [newTab]
          in
            ( { model | tabs = newTabList, newTab = Tabs.emptyTab }, Cmd.none )
        Err err ->
          ( { model | errorOccured = True }, Cmd.none)

    TabUpdated result ->
      case result of 
        Ok tab ->
          let 
            newTabList = 
              Tabs.replaceTab model.tabs model.newTab
          in
            ( { model | tabs = newTabList, newTab = Tabs.emptyTab }, Cmd.none )
        Err err ->
          ( { model | errorOccured = True }, Cmd.none)

    TabDeleted result ->
      case result of 
        Ok tab ->
          let 
            newTabList = 
              Tabs.deleteTab model.tabs model.newTab
          in
            ( { model | tabs = newTabList, newTab = Tabs.emptyTab }, Cmd.none )
        Err err ->
          ( { model | errorOccured = True }, Cmd.none)

    TaskCreated result ->
      case result of 
        Ok task ->
          let 
            taskCount = 
                (List.length model.highPriorityTasks) 
              + (List.length model.moderatePriorityTasks)
              + (List.length model.lowPriorityTasks)
              + (List.length model.generalPriorityTasks)

            updatedTaskLists = 
              Tasks.appendItemToTaskLists 
                model.newTask 
                task 
                taskCount 
                model.highPriorityTasks 
                model.moderatePriorityTasks 
                model.lowPriorityTasks 
                model.generalPriorityTasks
              
          in
            ( { model | highPriorityTasks = updatedTaskLists.highTaskList, 
                        moderatePriorityTasks = updatedTaskLists.moderateTaskList, 
                        lowPriorityTasks = updatedTaskLists.lowTaskList, 
                        generalPriorityTasks = updatedTaskLists.generalTaskList, newTask = Tasks.emptyTask }, Cmd.none )
        Err err ->
          ( { model | errorOccured = True }, Cmd.none)

    TaskUpdated result ->
      case result of 
        Ok tab ->
          let 
            updatedTaskLists = 
              Tasks.replaceItemInTaskLists
                model.newTask 
                model.highPriorityTasks
                model.moderatePriorityTasks 
                model.lowPriorityTasks 
                model.generalPriorityTasks
          in
            ( { model | highPriorityTasks = updatedTaskLists.highTaskList, 
                        moderatePriorityTasks = updatedTaskLists.moderateTaskList, 
                        lowPriorityTasks = updatedTaskLists.lowTaskList, 
                        generalPriorityTasks = updatedTaskLists.generalTaskList, newTask = Tasks.emptyTask }, Cmd.none )
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
  else if String.contains "task" commandRecord.view then handleEditTask model commandRecord
  else if String.contains "note" commandRecord.view then ( { model | currentView = Notes, commandString = "" }, Cmd.none )
  else ( model, Cmd.none )


-- TASKS UPDATE FUNCTIONS


handleCreateTask : Model -> List String -> ( Model, Cmd Msg )
handleCreateTask model valuesForCreate = 
  let
    updatedNewTask =
      Tasks.createNewTaskRecord valuesForCreate
  in
    ( { model | newTask = updatedNewTask, commandString = "" }, createTaskCommand model updatedNewTask )


handleEditTask : Model -> Converter.CommandRecord -> ( Model, Cmd Msg )
handleEditTask model commandRecord = 
  let
    tasks = 
      List.concat [model.highPriorityTasks, model.moderatePriorityTasks, model.lowPriorityTasks, model.generalPriorityTasks]

    updatedTask =
      Tasks.createUpdatedTaskRecord commandRecord tasks
  in
    ( { model | newTask = updatedTask, commandString = "" }, updateTaskCommand model updatedTask )


createTaskCommand : Model -> Tasks.Task -> Cmd Msg
createTaskCommand model task =
  Http.request
    { url = "http://localhost:8080/home/workspaces/" ++ String.fromInt model.workspaceId ++ "/task"
    , headers = [ HH.createHeader "X-CSRF-TOKEN" model.csrfToken ]
    , body = Http.jsonBody (Tasks.newTaskEncoder task)
    , method = "POST"
    , expect = Http.expectJson TaskCreated HH.postCreateResponseDecoder
    , timeout = Nothing
    , tracker = Nothing
    }


updateTaskCommand : Model -> Tasks.Task -> Cmd Msg
updateTaskCommand model task =
  Http.request
    { url = "http://localhost:8080/home/tasks/" ++ String.fromInt task.id
    , headers = [ HH.createHeader "X-CSRF-TOKEN" model.csrfToken ]
    , body = Http.jsonBody (Tasks.newTaskEncoder task)
    , method = "PUT"
    , expect = Http.expectJson TaskUpdated HH.postResponseDecoder
    , timeout = Nothing
    , tracker = Nothing
    }

-- NOTES UPDATE FUNCTIONS

-- TABS UPDATE FUNCTIONS


handleCreateTab : Model -> List String -> ( Model, Cmd Msg )
handleCreateTab model valuesForCreate =
  let
    updatedNewTab =
      Tabs.createNewTabRecord valuesForCreate model.newTab
  in
    ( { model | newTab = updatedNewTab, commandString = "" }, createTabCommand model updatedNewTab )


handleEditTab : Model -> Converter.CommandRecord -> ( Model, Cmd Msg )
handleEditTab model commandRecord = 
  let
    updatedTab =
      Tabs.createUpdatedTabRecord commandRecord model.tabs
  in
    ( { model | newTab = updatedTab, commandString = "" }, updateTabCommand model updatedTab )


createTabCommand : Model -> Tabs.Tab -> Cmd Msg
createTabCommand model tab =
  Http.request     
    { url = "http://localhost:8080/home/workspaces/" ++ String.fromInt model.workspaceId ++ "/tab"
    , headers = [ HH.createHeader "X-CSRF-TOKEN" model.csrfToken ]
    , body = Http.jsonBody (Tabs.newTabEncoder tab)
    , method = "POST"
    , expect = Http.expectJson TabCreated HH.postCreateResponseDecoder
    , timeout = Nothing
    , tracker = Nothing
    }


updateTabCommand : Model -> Tabs.Tab -> Cmd Msg
updateTabCommand model tab =
  Http.request
    { url = "http://localhost:8080/home/tabs/" ++ String.fromInt tab.id
    , headers = [ HH.createHeader "X-CSRF-TOKEN" model.csrfToken ]
    , body = Http.jsonBody (Tabs.newTabEncoder tab)
    , method = "PUT"
    , expect = Http.expectJson TabUpdated HH.postResponseDecoder
    , timeout = Nothing
    , tracker = Nothing
    }


deleteTabCommand : Model -> Tabs.Tab -> Cmd Msg
deleteTabCommand model tab =
  Http.request
    { url = "http://localhost:8080/home/tabs/" ++ String.fromInt tab.id
    , headers = [ HH.createHeader "X-CSRF-TOKEN" model.csrfToken ]
    , body = Http.jsonBody (Tabs.newTabEncoder tab)
    , method = "DELETE"
    , expect = Http.expectJson TabDeleted HH.postResponseDecoder
    , timeout = Nothing
    , tracker = Nothing
    }


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


renderTask : Tasks.Task -> Html Msg
renderTask task = 
  div [ class "column" ]
  [ div [ class "columns" ] 
    [ div [ class "column", class "is-full", class "task-container" ]
      [ div [ class "strike-through-on-hover" ] 
        [ div [ class "task-check-box" ] []
        , div [ class "task-item"] [ text task.name ]
        ]
      , button 
          [ class "button"
          , class "is-small"
          , class "is-outlined"
          , class "edit-task-button"
          , class "task-item"
          , onClick ( EnterEditTaskMode task )
          ] [ text "Edit" ]
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


renderTab : Tabs.Tab -> Html Msg
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
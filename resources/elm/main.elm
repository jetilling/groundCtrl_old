port module Main exposing (..)

import Browser
import Http
import Json.Encode as Encode
import Json.Decode exposing (Decoder, field, string, bool, int, map, map2)
import Html exposing (Html, Attribute, button, div, text, p, label, input, h4, a, ul, li, span, section, nav)
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
  , completedTasks : List Tasks.Task
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
  , completedTasks : List Tasks.Task
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
    flags.completedTasks
    Tasks.emptyTask
    False)
  , Cmd.none
  )


-- UPDATE


type Msg
  = OpenBrowserTabs
  | CloseBrowserTabs
  | OpenBrowserTab Tabs.Tab
  | UpdateCommandString String
  | KeyDown Int
  | EnterEditTabMode Tabs.Tab
  | EnterEditTaskMode Tasks.Task
  | DeleteTab Tabs.Tab
  | CompleteTask Tasks.Task
  | UndoTask Tasks.Task
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

    OpenBrowserTab tab ->
      ( { model | browserTabsAreOpen = True }, openBrowserTabs [tab] )

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
    
    CompleteTask task ->
      handleCompleteTask model task.uiid

    UndoTask task ->
      handleUndoCompleteTask model task.uiid

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
                model.completedTasks
              
          in
            ( { model | highPriorityTasks = updatedTaskLists.highTaskList
                      ,  moderatePriorityTasks = updatedTaskLists.moderateTaskList
                      ,  lowPriorityTasks = updatedTaskLists.lowTaskList
                      ,  generalPriorityTasks = updatedTaskLists.generalTaskList, newTask = Tasks.emptyTask }, Cmd.none )
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
                model.completedTasks
          in
            ( { model | highPriorityTasks = updatedTaskLists.highTaskList
                      , moderatePriorityTasks = updatedTaskLists.moderateTaskList 
                      , lowPriorityTasks = updatedTaskLists.lowTaskList
                      , generalPriorityTasks = updatedTaskLists.generalTaskList
                      , completedTasks = updatedTaskLists.completedTaskList
                      , newTask = Tasks.emptyTask }, Cmd.none )
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

    -- else if String.startsWith "delete" lowerCaseCmd then

    else if commandRecord.function == "complete" then handleCompleteCommand model commandRecord True
    else if commandRecord.function == "undo" then handleCompleteCommand model commandRecord False

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


handleCompleteCommand : Model -> Converter.CommandRecord -> Bool -> ( Model, Cmd Msg )
handleCompleteCommand model commandRecord completeTaskToggle = 
  if String.contains "task" commandRecord.view then 
    if completeTaskToggle then handleCompleteTask model commandRecord.itemId
    else handleUndoCompleteTask model commandRecord.itemId
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
    ( { model | newTask = updatedTask, commandString = "" }
    , updateTaskCommand model updatedTask ("http://localhost:8080/home/tasks/" ++ String.fromInt updatedTask.id) )


handleCompleteTask : Model -> String -> ( Model, Cmd Msg )
handleCompleteTask model itemId = 
  let 
    tasks = 
      List.concat [model.highPriorityTasks, model.moderatePriorityTasks, model.lowPriorityTasks, model.generalPriorityTasks]

    updatedTask = 
      Tasks.createCompletedTask itemId tasks
  in 
    ( { model | newTask = updatedTask, commandString = "" }
    , updateTaskCommand model updatedTask ("http://localhost:8080/home/tasks/" ++ String.fromInt updatedTask.id ++ "/update-complete") )


handleUndoCompleteTask : Model -> String -> ( Model, Cmd Msg )
handleUndoCompleteTask model itemId =
  let
    updatedTask = 
      Tasks.undoCompletedTask itemId model.completedTasks
  in 
    ( { model | newTask = updatedTask, commandString = "" }
    , updateTaskCommand model updatedTask ("http://localhost:8080/home/tasks/" ++ String.fromInt updatedTask.id ++ "/update-complete") )



createTaskCommand : Model -> Tasks.Task -> Cmd Msg
createTaskCommand model task =
  Http.request
    { url = "http://localhost:8080/home/workspaces/" ++ String.fromInt model.workspaceId ++ "/task"
    , headers = [ HH.createHeader "X-CSRF-TOKEN" model.csrfToken ]
    , body = Http.jsonBody (Tasks.taskEncoder task)
    , method = "POST"
    , expect = Http.expectJson TaskCreated HH.postCreateResponseDecoder
    , timeout = Nothing
    , tracker = Nothing
    }


updateTaskCommand : Model -> Tasks.Task -> String -> Cmd Msg
updateTaskCommand model task url =
  Http.request
    { url = url
    , headers = [ HH.createHeader "X-CSRF-TOKEN" model.csrfToken ]
    , body = Http.jsonBody (Tasks.taskEncoder task)
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
    [ renderHighPriorityTasks model
    , renderModeratePriorityTasks model
    , renderLowPriorityTasks model
    , renderGeneralTasks model
    , div [ class "column", class "is-one-fifth" ]  
        [ h4 [ class "title" ] [text "Completed" ]
        , div [ class "black-left-border" ] 
          ( List.map renderCompletedTask model.completedTasks )
        ]
      ]
    ]


renderHighPriorityTasks : Model -> Html Msg
renderHighPriorityTasks model =
  div [ class "column", class "is-one-fifth" ] 
  [ h4 [ class "title", class "red-text" ] [text "High Priority"]
  , div [ class "red-left-border" ]
    ( List.map renderTask model.highPriorityTasks )
  ]


renderModeratePriorityTasks : Model -> Html Msg
renderModeratePriorityTasks model =
  div [ class "column", class "is-one-fifth" ] 
  [ h4 [ class "title", class "orange-text" ] [text "Moderate Priority" ]
  , div [ class "orange-left-border" ]
    ( List.map renderTask model.moderatePriorityTasks )
  ]


renderLowPriorityTasks : Model -> Html Msg
renderLowPriorityTasks model =
  div [ class "column", class "is-one-fifth" ] 
  [ h4 [ class "title", class "green-text" ] [text "Low Priority" ]
  , div [ class "green-left-border" ]
    ( List.map renderTask model.lowPriorityTasks )
  ]


renderGeneralTasks : Model -> Html Msg
renderGeneralTasks model =
  div [ class "column", class "is-one-fifth" ] 
  [ h4 [ class "title", class "blue-text" ] [text "General Tasks" ]
  , div [ class "blue-left-border" ]
    ( List.map renderTask model.generalPriorityTasks )
  ]


renderTask : Tasks.Task -> Html Msg
renderTask task = 
  div [ class "box", class "transparent-box-with-shadow" ]
    [ div [ class "media" ] 
      [ div [ class "media-content", class "task-container" ]
        [ div [ class "content" ] 
          [ div [ class "strike-through-on-hover" ] 
            [ div [ class "task-item"
                  , onClick ( CompleteTask task )
                  ] [ text task.name ]
            ]
          ]
        , nav [ class "level" ]
          [ div [ class "level-left" ]
            [ button 
              [ class "level-item"
              , class "button"
              , class "is-small"
              , class "is-dark"
              , class "edit-task-button"
              , class "task-item"
              , onClick ( EnterEditTaskMode task )
              ] [ text "Edit" ]
          , div [ class "task-item", class "tag", class "is-dark", class "level-item" ] [ text ("id: " ++ task.uiid) ]
          ]
        ]
      ]
    ]
  ]


renderCompletedTask : Tasks.Task -> Html Msg
renderCompletedTask task = 
  div [ class "box", class "transparent-box" ]
  [ div [ class "media"
        , class (case task.priority of 
                  "high" -> 
                    "red-left-border"
                  "moderate" ->
                    "orange-left-border"
                  "low" -> 
                    "green-left-border"
                  "general" ->
                    "blue-left-border"
                  _ ->
                    "blue-left-border"
                ) 
        ] 
    [ div [ class "media-content", class "task-container" ]
      [ div [ class "content"] [ div [ class "task-item"] [ text task.name ]]
      , nav [ class "level" ]
          [ div [ class "level-left" ]
            [ button 
              [ class "level-item"
              , class "button"
              , class "is-small"
              , class "is-dark"
              , class "edit-task-button"
              , class "task-item"
                , onClick ( UndoTask task )
                ] [ text "Undo" ]
            , div [ class "task-item", class "tag", class "is-dark", class "level-item" ] [ text ("id: " ++ task.uiid) ]
          ]
        ]
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
  div [ class "column", class "is-one-fifth"]
  [ div [ class "box", class "transparent-box-with-shadow"]
    [ div [ class "media" ] 
      [ div [ class "media-content" ]
        [ div [ class "content" ] 
          [ a [ href tab.url, class "link", class "task-item" ] [ text tab.name ]
          , button 
                [ class "button"
                , class "is-small"
                , class "is-dark"
                , class "edit-task-button"
                , class "task-item"
                , onClick ( OpenBrowserTab tab )
                ] [ text "Open"] 
          ]
        , nav [ class "level" ]
          [ div [ class "level-left" ]
            [ button 
                [ class "level-item"
                , class "button"
                , class "is-small"
                , class "is-dark"
                , class "edit-task-button"
                , class "task-item"
                , onClick ( EnterEditTabMode tab )
                ] [ text "Edit" ]
            , div [ class "task-item", class "tag", class "is-dark", class "level-item" ] [ text ("id: " ++ tab.uiid) ]
            , button 
                [ class "level-item"
                , class "button"
                , class "is-small"
                , class "is-dark"
                , class "edit-task-button"
                , class "task-item"
                , onClick ( DeleteTab tab )
                ] [ text "Delete"]
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
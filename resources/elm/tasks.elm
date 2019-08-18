module Tasks exposing ( Task
                      , emptyTask
                      , taskEncoder
                      , createNewTaskRecord
                      , createUpdatedTaskRecord
                      , createCompletedTask
                      , undoCompletedTask
                      , appendItemToTaskLists
                      , replaceItemInTaskLists
                      )


import Json.Encode as Encode
import Json.Decode exposing (Decoder, field, string, bool, int, map, map2)
import Debug

import Utilities
import Converter
import HttpHelper as HH

type alias Task = 
  { id : Int
  , name : String
  , completed : Bool
  , priority : String
  , uiid : String
  }

type alias UpdateTaskListResponse =
  { highTaskList : List Task
  , moderateTaskList : List Task
  , lowTaskList : List Task
  , generalTaskList : List Task
  , completedTaskList : List Task
  }

emptyTask : Task
emptyTask =
  { id = 0 
  , name = ""
  , completed = False
  , priority = ""
  , uiid = ""
  }

taskEncoder : Task -> Encode.Value
taskEncoder task =
  Encode.object
    [ ( "name", Encode.string task.name )
    , ( "priority", Encode.string task.priority )
    , ( "completed", Encode.bool task.completed )
    ]


createNewTaskRecord : List String -> Task
createNewTaskRecord valuesForCreate = 
  let
    name = 
      Utilities.parseFirstArgument valuesForCreate

    priority =
      Utilities.parseSecondArgument valuesForCreate
  in
    { emptyTask | name = name, priority = priority }


createUpdatedTaskRecord : Converter.CommandRecord -> List Task -> Task
createUpdatedTaskRecord commandRecord tasks = 
  let
    matchingTask =
      findMatchingTask commandRecord.itemId tasks

    name = 
      Utilities.parseFirstArgument commandRecord.arguments

    priority = 
      Utilities.parseSecondArgument commandRecord.arguments

    updatedTask =
      { id = matchingTask.id, name = name, priority = priority, completed = False, uiid = commandRecord.itemId }
  in 
    updatedTask


createCompletedTask : String -> List Task -> Task 
createCompletedTask itemId tasks = 
  let
    matchingTask =
      findMatchingTask itemId tasks

    updatedTask = 
      { matchingTask | completed = True }
  in
    updatedTask


undoCompletedTask : String -> List Task -> Task
undoCompletedTask itemId tasks =
  let 
    matchingTask = 
      findMatchingTask itemId tasks 

    updatedTask =
      { matchingTask | completed = False }
  in 
    updatedTask



appendItemToTaskLists : Task -> HH.CreateResponse -> Int -> List Task -> List Task -> List Task -> List Task -> List Task -> UpdateTaskListResponse
appendItemToTaskLists modelNewTask taskResponse taskCount highPriorityTasks moderatePriorityTasks lowPriorityTasks generalPriorityTasks completedTasks = 
  let
    newTask = 
      addTaskId modelNewTask taskResponse taskCount

    highTaskList = 
      if newTask.priority == "high" then List.append highPriorityTasks [newTask]
      else highPriorityTasks
    
    moderateTaskList =
      if newTask.priority == "moderate" then List.append moderatePriorityTasks [newTask]
      else moderatePriorityTasks

    lowTaskList =
      if newTask.priority == "low" then List.append lowPriorityTasks [newTask]
      else lowPriorityTasks

    generalTaskList =
      if newTask.priority == "general" then List.append generalPriorityTasks [newTask]
      else generalPriorityTasks
  in
    { highTaskList = highTaskList
    , moderateTaskList = moderateTaskList
    , lowTaskList = lowTaskList
    , generalTaskList = generalTaskList 
    , completedTaskList = completedTasks
    }


replaceItemInTaskLists : Task -> List Task -> List Task -> List Task -> List Task -> List Task -> UpdateTaskListResponse
replaceItemInTaskLists newTask highPriorityTasks moderatePriorityTasks lowPriorityTasks generalPriorityTasks completedTasks = 
  let

    tasks = 
      List.concat [highPriorityTasks, moderatePriorityTasks, lowPriorityTasks, generalPriorityTasks]

    originalTask = 
      case List.head (findTask tasks newTask) of 
          Just item ->
            item
          Nothing ->
            emptyTask
    
    priorityChange = 
      if originalTask.priority /= newTask.priority then
        True 
      else 
        False 

    highTaskList =
      alterPriorityInTaskList priorityChange originalTask newTask "high" highPriorityTasks
    
    moderateTaskList =
      alterPriorityInTaskList priorityChange originalTask newTask "moderate" moderatePriorityTasks

    lowTaskList =
      alterPriorityInTaskList priorityChange originalTask newTask "low" lowPriorityTasks

    generalTaskList =
      alterPriorityInTaskList priorityChange originalTask newTask "general" generalPriorityTasks

    completedTaskList = 
      if newTask.completed then
        List.append completedTasks [newTask]
      else
        findAndRemoveCompletedTask completedTasks newTask
  in
    { highTaskList = highTaskList
    , moderateTaskList = moderateTaskList
    , lowTaskList = lowTaskList
    , generalTaskList = generalTaskList 
    , completedTaskList = completedTaskList
    }


alterPriorityInTaskList : Bool -> Task -> Task -> String -> List Task -> List Task 
alterPriorityInTaskList priorityChange originalTask newTask priority taskList =
  if newTask.completed then
    if originalTask.priority == priority then
      deleteTaskFromList taskList originalTask
    else 
      taskList
  else if priorityChange then 
    if originalTask.priority == priority then
      deleteTaskFromList taskList originalTask
    else if newTask.priority == priority then
      List.append taskList [newTask]
    else taskList
  else 
    if newTask.priority == priority then replaceTask taskList newTask
    else taskList


addTaskId : Task -> HH.CreateResponse -> Int -> Task
addTaskId currentTask taskResponse taskCount = 
  { currentTask | id = taskResponse.newItemId, uiid = String.fromInt (taskCount + 1) }


replaceTask : List Task -> Task -> List Task
replaceTask tasks newTask =
  let
    replace task =
      if task.id == newTask.id then
        { task | name = newTask.name, priority = newTask.priority }
      else
        task
  in
    List.map replace tasks


findTask : List Task -> Task -> List Task
findTask tasks newTask = 
  let
    find task = 
      if task.id == newTask.id then 
        True 
      else
        False  
  in
    List.filter find tasks


deleteTaskFromList : List Task -> Task -> List Task
deleteTaskFromList tasks taskToDelete =
  let 
    delete task = 
      if task.id == taskToDelete.id then
        False 
      else
        True 
  in 
    List.filter delete tasks


findMatchingTask : String -> List Task -> Task
findMatchingTask itemId tasks =
  let
    findTaskIdMatch task = 
      if task.uiid == itemId then True
      else False
  in 
    case List.head (List.filter findTaskIdMatch tasks) of
      Just extractedTask ->
        extractedTask
      Nothing -> 
        emptyTask


findAndRemoveCompletedTask : List Task -> Task -> List Task
findAndRemoveCompletedTask completedTasks newTask =
  let 
    taskInCompleted = 
      case List.head (findTask completedTasks newTask) of 
        Just item ->
          True
        Nothing ->
          False
    
    updatedCompletedTasks = 
      if taskInCompleted then
        deleteTaskFromList completedTasks newTask
      else 
        completedTasks
  in 
    updatedCompletedTasks
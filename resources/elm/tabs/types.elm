module Types exposing (..)

import Http

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

-- Update Type

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
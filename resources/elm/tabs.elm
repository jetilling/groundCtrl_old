module Tabs exposing (..)


import Json.Encode as Encode
import Json.Decode exposing (Decoder, field, string, bool, int, map, map2)

import Converter exposing (..)
import Utilities exposing (..)

type alias Tab =
  { id : Int
  , url : String
  , name : String
  , uiid : String
  }


emptyTab : Tab
emptyTab =
  { id = 0 
  , url = ""
  , name = ""
  , uiid = ""
  }


createUpdatedTabRecord : Converter.CommandRecord -> List Tab -> Tab
createUpdatedTabRecord commandRecord tabList =
  let
    matchingTab =
      let
        findTabIdMatch tab = 
          if tab.uiid == commandRecord.itemId then True
          else False
      in 
        case List.head (List.filter findTabIdMatch tabList) of
          Just extractedTab ->
            extractedTab
          Nothing -> 
            emptyTab

    name = 
      Utilities.parseFirstArgument commandRecord.arguments

    url = 
      Utilities.parseSecondArgument commandRecord.arguments

    updatedTab =
      { id = matchingTab.id, name = name, url = url, uiid = commandRecord.itemId }
  in 
    updatedTab


createNewTabRecord : List String -> Tab -> Tab
createNewTabRecord nameUrlArguments tab =
  let
    name = 
      Utilities.parseFirstArgument nameUrlArguments

    url =
      Utilities.parseSecondArgument nameUrlArguments
  in
    { tab | name = name, url = url }


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


newTabEncoder : Tab -> Encode.Value
newTabEncoder tab =
  Encode.object
    [ ( "name", Encode.string tab.name )
    , ( "url", Encode.string tab.url )
    ]
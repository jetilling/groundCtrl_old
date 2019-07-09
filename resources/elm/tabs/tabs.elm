port module Tabs exposing (..)

import Types exposing (..)
import State exposing (..)
import View exposing (..)

import Browser




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

-- UPDATE

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
      handleTabCreated model result

    TabUpdated result ->
      handleTabUpdated model result

    TabDeleted result ->
      handleTabDeleted model result


-- SUBSCRIPTIONS

subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.none

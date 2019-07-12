module Main exposing (..)

import Browser
import Http

-- MAIN

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
  , workspaceId : Int
  , csrfToken : String 
  }

type alias Model = 
  { tabs : List Tab
  , currentView : CurrentView
  , workspaceId : Int
  , crsfToken : String
  , errorOccured : Bool
  }

type CurrentView
  = Tabs
  | Notes
  | Tasks

type alias Tab =
  { id : String
  , url : String
  , name : String
  }

init : Flags -> (Model, Cmd Msg)
init flags =
  ( Tasks
    flags.workspaceId
    flags.crsfToken
  , Cmd.none
  )


-- UPDATE


type Msg
  = GotText (Result Http.Error String)


update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    GotText result ->
      case result of
        Ok fullText ->
          (Success fullText, Cmd.none)

        Err _ ->
          (Failure, Cmd.none)



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.none



-- VIEW


view : Model -> Html Msg
view model =
  case model of
    Failure ->
      text "I was unable to load your book."

    Loading ->
      text "Loading..."

    Success fullText ->
      pre [] [ text fullText ]
module View exposing (..)

import Types exposing (..)

import Html exposing (Html, button, div, text, p, label, input, h4, a)
import Html.Events exposing (onClick, onInput)
import Html.Attributes exposing (class, classList, type_, placeholder, value, href)

view : Model -> Html Msg
view model =
  div [class "content"] 
    [ div [class "columns"]
      [ div [class "column"] [ p [class "title"] [text "Tabs"] ]
      , div [class "column"] [ renderMainFunctionButtons model ]
      ]
    , p [ class "subtitle" ] [ text "Manage workspace specific browser tabs"]
    , renderErrorMessage model
    , renderAddTabComponent model
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

renderMainFunctionButtons : Model -> Html Msg
renderMainFunctionButtons model =
  div [ class "columns", class "center-vetically"] 
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

renderErrorMessage : Model -> Html Msg
renderErrorMessage model =
  p [ classList 
      [ ("error-msg", True)
      , ("display-block", model.errorOccured)
      , ("no-display", not model.errorOccured)
      ] 
    ] [ text "An error occurred while trying to add a new tab" ]

renderAddTabComponent : Model -> Html Msg
renderAddTabComponent model =
  div [ classList 
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
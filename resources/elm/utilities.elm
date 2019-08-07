module Utilities exposing (parseFirstArgument, parseSecondArgument)

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
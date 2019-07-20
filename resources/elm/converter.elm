module Converter exposing (convertToAST, CommandRecord)

import Array

type alias CommandRecord = 
  { function : String
  , view : String
  , arguments : List String
  }

newCommandRecord : CommandRecord
newCommandRecord =
  { function = ""
  , view = ""
  , arguments = []
  }

convertToAST : String -> CommandRecord
convertToAST commandString = 
  let
      splitCmdAndArgumentList = 
        if String.contains "[" commandString then String.split "[" commandString
        else [commandString]

      cmdString =
        case List.head (List.take 1 splitCmdAndArgumentList) of 
          Just item ->
            item
          Nothing ->
           ""
        
      argumentString = 
        if List.length splitCmdAndArgumentList > 1 then
          case List.head (List.drop 1 splitCmdAndArgumentList) of 
            Just item ->
              String.dropRight 1 item
            Nothing ->
              ""
        else 
          ""

      splitCmdList =
        List.filter checkIfStringIsNotEmpty (String.split " " cmdString)

      function =
        case Array.get 0 (Array.fromList splitCmdList) of 
          Just item ->
            String.toLower item
          Nothing ->
            ""

      view =
        case Array.get 1 (Array.fromList splitCmdList) of 
          Just item ->
            String.toLower item
          Nothing ->
            ""

      updatedCommandRecord =
        { newCommandRecord | function = function, view = view }
  in
    formatArguments argumentString updatedCommandRecord


checkIfStringIsNotEmpty : String -> Bool
checkIfStringIsNotEmpty item =
  String.length item > 0

formatArguments : String -> CommandRecord -> CommandRecord
formatArguments argumentString updatedCommandRecord =
  if String.isEmpty argumentString then
    updatedCommandRecord
  else
    let
      argumentList =
        String.split "," argumentString

      formatArgument item = 
        String.trim item

      formattedArgumentList =
        List.map formatArgument argumentList

      completedCommandRecord = 
        { updatedCommandRecord | arguments = formattedArgumentList }
    in
      completedCommandRecord


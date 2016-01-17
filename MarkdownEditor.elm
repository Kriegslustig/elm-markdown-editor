module MarkdownEditor where

import Markdown
import Signal
import VirtualDom
import Graphics.Element exposing (Element)
import Html exposing (Html, Attribute, toElement, div, textarea, text, p)
import Html.Events exposing (on, targetValue)
import Html.Attributes exposing (style)

type alias Model =
  { text : Element
  }

type Action =
  Change String
  | Nope

update : Action -> Model -> Model
update action model =
  case action of
    Nope ->
      model

    Change md ->
      { model |
        text = Markdown.toElement md
      }

elemStyles : List (String, String)
elemStyles =
  [ ("float", "left")
  , ("width", "50%")
  , ("height", "100vh")
  , ("padding", "0")
  , ("margin", "0")
  ]

view : Signal.Address Action -> Model -> Html
view address model =
  div []
    [ textarea
      [ on "keyup" targetValue (Signal.message address << Change)
      , style <| ("border", "none") :: elemStyles
      ]
      [ text initialText ]
    , div
      [ style elemStyles ]
      [ VirtualDom.fromElement model.text ]
    ]

initialText =
  """# Hi

This is a simple Markdown editor
"""

init : Model
init =
  Model
    <| Markdown.toElement initialText

actions : Signal.Mailbox Action
actions =
  Signal.mailbox Nope

model : Signal Model
model =
  Signal.foldp update init actions.signal

main : Signal Html
main =
  Signal.map (view actions.address) model


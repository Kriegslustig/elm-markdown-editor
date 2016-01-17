module MarkdownEditor where

import Markdown
import Signal
import VirtualDom
import Graphics.Element exposing (Element)
import Html exposing (Html, Attribute, div, textarea, text, p)
import Html.Events exposing (on, targetValue)
import Html.Attributes exposing (style)

{-
  The Model Record comtains the compiled markdown
-}
type alias Model =
  { text : Element }

{-
  There are two actions
  Nope, which does nothing
  Change String, which rerenders the markdown
-}
type Action =
  Change String
  | Nope

{-
 The Initial text to be rendered
-}
initialText =
  """# Hi

This is a simple Markdown editor
"""

{-
  This is triggered each time a 'keyup' happens
-}
update : Action -> Model -> Model
update action model =
  case action of
    Nope ->
      model

    {-
      Recompile the markdown
    -}
    Change md ->
      { model |
        text = Markdown.toElement md
      }

{-
  Common styles for the textarea and the html container
-}
elemStyles : List (String, String)
elemStyles =
  [ ("float", "left")
  , ("width", "50%")
  , ("height", "100vh")
  , ("padding", "0")
  , ("margin", "0")
  ]

{-
  Renders the html and feeds Signals back to a given address
-}
view : Signal.Address Action -> Model -> Html
view address model =
  div []
    [ textarea
      [ on "keyup" targetValue <| Signal.message address << Change
      , style <| ("border", "none") :: elemStyles
      ]
      [ text initialText ]
    , div
      [ style elemStyles ]
      [ VirtualDom.fromElement model.text ]
    ]

{-
  Initializes a Model
-}
init : Model
init =
  Model
    <| Markdown.toElement initialText

{-
  A Mailbox to communicate through
-}
actions : Signal.Mailbox Action
actions =
  Signal.mailbox Nope

{-
  Creates a signal from Model
  It listenes to actions.signal
  Messages comming form actions.signal are routed to update
  The Address of actions.signal and the current model are passed to update
-}
model : Signal Action -> Signal Model
model signal =
  Signal.foldp update init signal

{-
  Listen to actions.signal and render the view
-}
main : Signal Html
main =
  Signal.map (view actions.address) (model actions.signal)


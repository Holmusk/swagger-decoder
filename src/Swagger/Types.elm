module Swagger.Types exposing (SwaggerSpecification, Info, Contact, License,
                               Scheme(..), Paths, PathItem, Operation, ExternalDocs,
                               Parameter, ParameterIn(..), ParameterBody(..), ParameterBodyOthersBody,
                               Items(..), ItemsBody, CollectionFormat(..), Schema(..), Reference,
                               Responses, Response, Header, Headers, Example, SecurityRequirement)

{-|  This module defines the types that make up a swagger schema

@docs SwaggerSpecification
@docs Info
@docs Contact
@docs License
@docs Scheme(..)
@docs Paths
@docs PathItem
@docs Operation
@docs ExternalDocs
@docs Parameter
@docs ParameterIn(..)
@docs ParameterBody(..)
@docs ParameterBodyOthersBody
@docs Items(..)
@docs ItemsBody
@docs CollectionFormat(..)
@docs Schema(..)
@docs Reference
@docs Responses
@docs Response
@docs Header
@docs Headers
@docs Example
@docs SecurityRequirement
-}

import Json.Decode as D
import Either exposing (Either)
import Dict exposing (Dict)

{-| -}
type alias SwaggerSpecification =
    { info : Info
    , host : Maybe String
    , basePath : Maybe String
    , schemes : List Scheme
    , consumes : List String
    , produces : List String
    , paths : Paths
    }

{-| -}
type alias Info =
    { title : String
    , description : Maybe String
    , termsOfService : Maybe String
    , contact : Maybe Contact
    , license : Maybe License
    , version : String
    }

{-| -}
type alias Contact =
    { name : Maybe String
    , url : Maybe String
    , email : Maybe String
    }

{-| -}
type alias License =
    { name : String
    , url : Maybe String
    }

{-| -}
type Scheme =
      Http
    | Https
    | Ws
    | Wss

{-| -}
type alias Paths = Dict String PathItem

{-| -}
type alias PathItem =
    { ref : Maybe String
    , get : Maybe Operation
    , put : Maybe Operation
    , post : Maybe Operation
    , delete : Maybe Operation
    , options : Maybe Operation
    , head : Maybe Operation
    , patch : Maybe Operation
    , parameters : Maybe (Either Parameter Reference)
    }

{-| -}
type alias Operation =
    { tags : List String
    , summary : Maybe String
    , description : Maybe String
    , externalDocs : Maybe ExternalDocs
    , operationId : Maybe String
    , consumes : List String
    , produces : List String
    , parameters : Maybe (Either Parameter Reference)
    , responses : Responses
    , schemes : List Scheme
    , deprecated : Bool
    , security : Maybe SecurityRequirement
    }

{-| -}
type alias ExternalDocs =
    { description : Maybe String
    , url : String
    }

{-| -}
type alias Parameter =
    { name : String
    , in_ : ParameterIn
    , description : Maybe String
    , required : Bool
    , parameterBody : ParameterBody
    }

{-| -}
type ParameterIn =
      Query
    | Header_
    | Path
    | FormData
    | Body

{-| -}
type ParameterBody =
      ParameterBodySchema Schema
    | ParameterBodyOthers ParameterBodyOthersBody

{-| -}
type alias ParameterBodyOthersBody =
    { type_ : String
    , format : Maybe String
    , allowEmptyValue : Bool
    , items : Maybe Items
    , collectionFormat : CollectionFormat
    }


{-| -}
type Items = Items ItemsBody

{-| -}
type alias ItemsBody =
    { type_ : String
    , format : Maybe String
    , items : Maybe Items
    , collectionFormat : CollectionFormat
    }

{-| -}
type CollectionFormat =
      Csv
    | Ssv
    | Tsv
    | Pipes
    | Multi

{-| Out of scope of this project to decode this -}
type Schema = Schema ()

{-| -}
type alias Reference =
    { ref : String
    }

{-| -}
type alias Responses =
    { default : Maybe (Either Response Reference)
    , get : Maybe (Either Response Reference)
    , put : Maybe (Either Response Reference)
    , post : Maybe (Either Response Reference)
    , delete : Maybe (Either Response Reference)
    , options : Maybe (Either Response Reference)
    , head : Maybe (Either Response Reference)
    , patch : Maybe (Either Response Reference)
    }

{-| -}
type alias Response =
    { description : String
    , schema : Maybe Schema
    , headers : Maybe Headers
    , examples : Maybe Example
    }

{-| -}
type alias Headers = Dict String Header

{-| -}
type alias Header =
    { description : Maybe String
    , type_ : String
    , format : Maybe String
    , items : Maybe Items
    , collectionFormat : CollectionFormat
    }

{-| -}
type alias Example = Dict String D.Value

{-| -}
type alias SecurityRequirement = Dict String (List String)

module Swagger.Decoder exposing (swaggerDecoder)

import Json.Decode as D exposing (Decoder, maybe)
import Json.Decode.Pipeline exposing (required, optional)
import Either.Decode exposing (either)

import Swagger.Types exposing (..)

swaggerDecoder : Decoder SwaggerSpecification
swaggerDecoder = D.field "swagger" D.string
    |> D.andThen (\swaggerVersion -> 
            if swaggerVersion == "2.0" then
                D.succeed SwaggerSpecification
                    |> required "info" infoDecoder
                    |> optional "host" (maybe D.string) Nothing
                    |> optional "basePath" (maybe D.string) Nothing
                    |> optional "schemes" (D.list schemeDecoder) []
                    |> optional "consumes" (D.list D.string) []
                    |> optional "produces" (D.list D.string) []
                    |> required "paths" pathsDecoder
            else
                D.fail "Swagger version must be 2.0"
        )

infoDecoder : Decoder Info
infoDecoder =
    D.succeed Info
        |> required "title" D.string
        |> optional "description" (maybe D.string) Nothing
        |> optional "termsOfService" (maybe D.string) Nothing
        |> optional "contact" (maybe contactDecoder) Nothing
        |> optional "license" (maybe licenseDecoder) Nothing
        |> required "version" D.string

contactDecoder : Decoder Contact
contactDecoder =
    D.succeed Contact
        |> optional "name" (maybe D.string) Nothing 
        |> optional "url" (maybe D.string) Nothing
        |> optional "email" (maybe D.string) Nothing

licenseDecoder : Decoder License
licenseDecoder =
    D.succeed License
        |> required "name" D.string
        |> optional "url" (maybe D.string) Nothing

schemeDecoder : Decoder Scheme
schemeDecoder =
    D.string |> D.andThen (\x -> 
        case x of
            "http" -> D.succeed Http
            "https" -> D.succeed Https
            "ws" -> D.succeed Ws
            "wss" -> D.succeed Wss
            _ -> D.fail <| "Invalid scheme value, expecting one of http, https, ws, wss but got " ++ x
        )


pathsDecoder : Decoder Paths
pathsDecoder =
    D.dict pathItemDecoder

pathItemDecoder : Decoder PathItem
pathItemDecoder =
    D.succeed PathItem
        |> optional "$ref" (maybe D.string) Nothing
        |> optional "get" (maybe operationDecoder) Nothing
        |> optional "put" (maybe operationDecoder) Nothing
        |> optional "post" (maybe operationDecoder) Nothing
        |> optional "delete" (maybe operationDecoder) Nothing
        |> optional "options" (maybe operationDecoder) Nothing
        |> optional "head" (maybe operationDecoder) Nothing
        |> optional "patch" (maybe operationDecoder) Nothing
        |> optional "parameters" (maybe <| either parameterDecoder referenceDecoder) Nothing

operationDecoder : Decoder Operation
operationDecoder =
    D.succeed Operation
        |> optional "tags" (D.list D.string) []
        |> optional "summary" (maybe D.string) Nothing
        |> optional "description" (maybe D.string) Nothing
        |> optional "externalDocs" (maybe externalDocsDecoder) Nothing
        |> optional "operationId" (maybe D.string) Nothing
        |> optional "consumes" (D.list D.string) []
        |> optional "produces" (D.list D.string) []
        |> optional "parameters" (maybe <| either parameterDecoder referenceDecoder) Nothing
        |> required "responses" responsesDecoder
        |> optional "schemes" (D.list schemeDecoder) []
        |> optional "deprecated" D.bool False
        |> optional "security" (maybe securityRequirementDecoder) Nothing


externalDocsDecoder : Decoder ExternalDocs
externalDocsDecoder = 
    D.succeed ExternalDocs
        |> optional "description" (maybe D.string) Nothing
        |> required "url" D.string

parameterDecoder : Decoder Parameter
parameterDecoder =
    D.map5 Parameter
        (D.field "name" D.string)
        (D.field "in" parameterInDecoder)
        (maybe <| D.field "description" D.string)
        (D.oneOf [D.field "required" D.bool, D.succeed False])
        (D.field "in" parameterInDecoder
            |> D.andThen (\inParameter ->
                    case inParameter of
                        Body -> parameterBodySchemaDecoder
                        _    -> parameterBodyOthersDecoder
                )
        )

parameterBodySchemaDecoder : Decoder ParameterBody
parameterBodySchemaDecoder =
    D.map ParameterBodySchema schemaDecoder

parameterBodyOthersDecoder : Decoder ParameterBody
parameterBodyOthersDecoder =
    D.map ParameterBodyOthers
        (D.succeed ParameterBodyOthersBody
            |> required "type" D.string
            |> optional "format" (maybe D.string) Nothing
            |> optional "allowEmptyValue" D.bool False
            |> optional "items" (maybe itemsDecoder) Nothing
            |> optional "collectionFormat" collectionFormatDecoder Csv)

itemsDecoder : Decoder Items
itemsDecoder =
    D.map Items
        (D.succeed ItemsBody
            |> required "type" D.string
            |> optional "formal" (maybe D.string) Nothing
            |> optional "items" (maybe <| D.lazy (\_ -> itemsDecoder)) Nothing
            |> optional "collectionFormat" collectionFormatDecoder Csv)

schemaDecoder : Decoder Schema
schemaDecoder =
    D.map Schema <| D.succeed ()

parameterInDecoder : Decoder ParameterIn
parameterInDecoder =
    D.string |> D.andThen (\x -> 
        case x of
            "query" -> D.succeed Query
            "header" -> D.succeed Header_
            "path" -> D.succeed Path
            "formData" -> D.succeed FormData
            "body" -> D.succeed Body
            _ -> D.fail <| "Invalid _in_ value, expecting one of query, header, path, formData, body but got " ++ x
        )

collectionFormatDecoder : Decoder CollectionFormat
collectionFormatDecoder =
    D.string |> D.andThen (\x -> 
        case x of
            "csv" -> D.succeed Csv
            "ssv" -> D.succeed Ssv
            "tsv" -> D.succeed Tsv
            "pipes" -> D.succeed Pipes
            "multi" -> D.succeed Multi
            _ -> D.fail <| "Invalid _in_ value, expecting one of csv, ssv, tsv, pipes, multi but got " ++ x
        )

referenceDecoder : Decoder Reference
referenceDecoder =
    D.succeed Reference
        |> required "$ref" D.string

responsesDecoder : Decoder Responses
responsesDecoder =
    D.succeed Responses
        |> optional "default" (maybe <| either responseDecoder referenceDecoder) Nothing
        |> optional "get" (maybe <| either responseDecoder referenceDecoder) Nothing
        |> optional "put" (maybe <| either responseDecoder referenceDecoder) Nothing
        |> optional "post" (maybe <| either responseDecoder referenceDecoder) Nothing
        |> optional "delete" (maybe <| either responseDecoder referenceDecoder) Nothing
        |> optional "options" (maybe <| either responseDecoder referenceDecoder) Nothing
        |> optional "head" (maybe <| either responseDecoder referenceDecoder) Nothing
        |> optional "patch" (maybe <| either responseDecoder referenceDecoder) Nothing

responseDecoder : Decoder Response
responseDecoder =
    D.succeed Response
        |> required "description" D.string
        |> optional "schema" (maybe schemaDecoder) Nothing
        |> optional "headers" (maybe headersDecoder) Nothing
        |> optional "examples" (maybe exampleDecoder) Nothing

headersDecoder : Decoder Headers
headersDecoder =
    D.dict headerDecoder

headerDecoder : Decoder Header
headerDecoder =
    D.succeed Header
        |> optional "description" (maybe D.string) Nothing
        |> required "type" D.string
        |> optional "format" (maybe D.string) Nothing
        |> optional "items" (maybe itemsDecoder) Nothing
        |> optional "collectionFormat" (collectionFormatDecoder) Csv

exampleDecoder : Decoder Example
exampleDecoder = D.dict D.value

securityRequirementDecoder : Decoder SecurityRequirement 
securityRequirementDecoder = D.dict <| D.list D.string
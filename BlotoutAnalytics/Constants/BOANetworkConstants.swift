//
//  BOANetworkConstants.swift
//  BlotoutAnalyticsSDK
//
//  Created by Poonam Tiwari on 21/03/22.
//

import Foundation

let BOSDK_MAJOR_VERSION = 0
let BOSDK_MINOR_VERSION = 10
let BOSDK_PATCH_VERSION = 2

let BO_GET = "GET"
let BO_POST = "POST"
let BO_PUT = "PUT"
let BO_CONTENT_TYPE = "Content-Type"
let BO_APPLICATION_JSON = "application/json"
let BO_TOKEN = "token"
let BO_ACCEPT = "Accept"
let BO_VERSION = "version"

let BO_META = "meta"
let BO_KEY = "key"
let BO_DATA = "data"
let BO_IV = "iv"
//let BO_PII = "pii"
//let BO_PHI = "phi"

let BO_USER_ID = "userid"

let BO_EVENT_MAP_ID = "map_id"
let BO_EVENT_MAP_PROVIDER = "map_provider"

let BO_SDK_START = "sdk_start"

let BO_VISIBILITY_VISIBLE = "visibility_visible"

let BO_VISIBILITY_HIDDEN = "visibility_hidden"

//transaction events
let BO_EVENT_TRANSACTION_NAME = "transaction"

//item events
let BO_EVENT_ITEM_NAME = "item"

//Persona events
let BO_EVENT_PERSONA_NAME = "persona"

let BO_APP_VERSION = "app_version"
let BO_EVENTS = "events"
let BO_EVENTS_TIME = "evt"
let BO_MESSAGE_ID = "mid"
let BO_EVENT_NAME_MAPPING = "evn"
let BO_SCREEN_NAME = "scrn"
let BO_CRYPTO_IVX = "Q0BG17E2819IWZYQ"
let BOA_DEBUG = "BOA-DEBUG"
let BO_DEFAULT_EVENT_PUSH_TIME = 3
let BO_SDK_REST_API_MANIFEST_PULL_PATH = "v1/manifest/pull"
let BO_SDK_REST_API_EVENTS_PUSH_PATH = "v1/events/publish"
let BO_ANALYTICS_ROOT_USER_DEFAULTS_KEY = "com.blotout.sdk.Analytics.Root"
let BO_ANALYTICS_USER_BIRTH_TIME_STAMP_KEY = "com.blotout.sdk.Analytics.Root.UserBirthTimeStamp"
let BO_ANALYTICS_ALL_DEV_CODIFIED_CUSTOM_EVENTS = "com.blotout.sdk.Analytics.Dev_Custom_Event"
let BO_ANALYTICS_USER_UNIQUE_KEY = "UserUniqueId"
let BO_SESSION_ID = "session_id"
let BO_VERSION_KEY = "BOVersionKey"
let BO_BUILD_KEYV1 = "BOBuildKey"
let BO_BUILD_KEYV2 = "BOBuildKeyV2"
let BO_SYSTEM = "system"
let BO_CODIFIED = "codified"
let BO_SCREEN = "screen"
let BO_TYPE = "type"
let BO_PATH = "path"
let BO_PAGE_TITLE = "page_title"

let MANIFEST_PHI_PUBLIC_KEY = 5997
let MANIFEST_PII_PUBLIC_KEY = 5998
let MANIFEST_SYSTEM_EVENTS = 5001

let BO_APPLICATION_OPENED = 11001
let BO_APPLICATION_INSTALLED = 11002
let BO_APPLICATION_UPDATED = 11003
let BO_PUSH_NOTIFICATION_TAPPED = 11004
let BO_PUSH_NOTIFICATION_RECEIVED = 11005
let BO_REGISTER_FOR_REMOTE_NOTIFICATION = 11006
let BO_DEEP_LINK_OPENED = 11007
let BO_APPLICATION_BACKGROUNDED = 11008
let BO_APP_TRACKING = 11009
let BO_TRANSACTION_COMPLETED = 11010

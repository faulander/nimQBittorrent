## nimtm - a wrapper for the QBittorrent Web-API
## 
## QUICK EXAMPLE
## --------------
## ::
##  import nimtm
##  let connection = initQb("http://127.0.0.1:8080", "admin", "adminadmin")
##  conn.login()
##  if conn.connected:
##    var torrents = conn.getTorrents()
##    for torrent in torrents:
##      echo getTorrentFiles(torrent["hash"])
##

import 
  net, 
  strutils, 
  httpclient,
  json,
  tables,
  typetraits,
  logging
from uri import
  encodeQuery

const 
  BASE          = "/api/v2/"
  BASE_AUTH     = BASE & "auth/"
  BASE_APP      = BASE & "app/"
  BASE_LOG      = BASE & "log/"
  BASE_SYNC     = BASE & "sync/"
  BASE_TRANSFER = BASE & "transfer/"
  BASE_TORRENT  = BASE & "torrents/"
  BASE_RSS      = BASE & "rss/"
  BASE_SEARCH   = BASE & "search/"

var consoleLog = newConsoleLogger(fmtStr="[$datetime] - $levelname - ", levelThreshold=lvlDebug)
addHandler(consoleLog)

type
  Qb* = object
    cookie: string
    url: string
    connected: bool 
    username: string
    password: string
    referer: string

  HttpHeaders* = ref object
    table*: TableRef[string, seq[string]]

proc initQb*(url:string, username:string, password:string): Qb = 
  ## Initializes a Session. 
  return Qb(url: url,
            username: username,
            password: password)

proc boolToStr(parameter: bool): string = 
  if parameter:
    result = "true"
  else:
    result = "false"

proc hashesToStr(hashes: seq[string]): string = 
  var h:string
  if hashes.len == 0:
      result = ""
  else:
    for hash in hashes:
      h = h & hash & "|"
    h = h[0 .. len(h)-2] # cuts of the last |
    result = h

template getData(): untyped =
  let client = newHttpClient()
  client.headers = newHttpHeaders({ "cookie": cookie })
  let finalUrl = url & base & meth
  debug("Proc: getDataFromApi, URL: ", finalUrl, ", Method: ", meth)
  let response {.inject.} = client.request(finalUrl, httpMethod = postorget)
  

proc getDataFromApi(cookie: string, url:string, base:string, meth:string, postorget = HttpGet): string =  
  getData()
  if response.status == "200 OK":
    result = response.body
  else:
    result = "Error"

proc getDataFromApiJSON(cookie: string, url:string, base:string, meth:string, postorget = HttpGet): JsonNode 
 =  
  getData()
  if response.status == "200 OK":
    result = parseJson(response.body)
  else:
    result = %*{"error": "Method " & meth & " failed."}

proc login*(self: var Qb): bool = ## tries to login with the credentials provided in initQb
  ## Logs into the QBittorrent WebAPI with the credentials provided in initQb.
  let ipAdress = $getPrimaryIPAddr().address_v4[0] & "." &
        $getPrimaryIPAddr().address_v4[1] & "." &
        $getPrimaryIPAddr().address_v4[2] & "." &
        $getPrimaryIPAddr().address_v4[3] 
  let client = newHttpClient()
  let body = %*{
      "username": self.username,
      "password": self.password
  }
  let finalUrl = self.url & BASE_AUTH & "login?" & "username=" & self.username & "&password=" & self.password
  let response = client.request(finalUrl, httpMethod = HttpGet, body = $body)
  var tmpHeader: string
  for header, index in response.headers["set-cookie"]:
   tmpHeader = tmpHeader & index
  var strPoint = find(tmpHeader, ";")
  var finalHeader = tmpHeader[0 .. strPoint-1]
  if response.status == "200 OK":
    self.connected = true
    self.referer = ipAdress
    self.cookie = finalHeader
    result = true
    debug("Proc: login, Status: ", response.status, ", Connected: ", self.connected, ", Referer: ", self.referer, ", Cookie: ", self.cookie)
  else:
    return false

proc logout*(self: var Qb): bool = 
  ## Logs out of the current session
  let client = newHttpClient()
  client.headers = newHttpHeaders({ "cookie": self.cookie })
  let finalUrl = self.url & BASE_AUTH & "logout"
  let response = client.request(finalUrl, httpMethod = HttpGet)
  if response.status == "200 OK":
    self.connected = false
    self.referer = ""
  debug("Proc: logout, Status: ", response.status, ", Connected: ", self.connected, ", Referer: ", self.referer)
  result = true

proc getVersion*(self: Qb): JsonNode = 
  ## returns the version of the QBittorrent client
  var res = getDataFromApi(self.cookie, self.url, BASE_APP, "version")
  var j = %*{"version": res}
  debug (j)
  result = j

proc getWebAPIVersion*(self: Qb): JsonNode = 
  ## returns the version of the QB API
  var res = getDataFromApi(self.cookie, self.url, BASE_APP, "webapiVersion")
  var j = %*{"webapiversion": res}
  debug (j)
  result = j
 
proc getBuildInfo*(self: Qb): JsonNode = 
  ## Returns a JSON of the build information of QBittorrents libraries
  result = getDataFromApiJSON(self.cookie, self.url, BASE_APP, "buildInfo")
  debug (result)

proc getPreferences*(self: Qb): JsonNode = 
  ## Returns all preferences of the QBittorrent Instance.
  #TODO Replace choice fields
  result = getDataFromApiJSON(self.cookie, self.url, BASE_APP, "preferences")
  debug (result)

proc getMainLog*(self: Qb, normal = false, info = false, warning = true, critical = true, last_known_id = -1): JsonNode =
  ## Get's the logs from the current Qt instance. The level can be set by enabling or disabling the loglevels.
  ## Timeframe can be set by filling the `last_known_id` with an integer field different than -1.
  #TODO Replace choice fields
  var queryString = encodeQuery({
                      "normal": boolToStr(normal),
                      "info": boolToStr(info),
                      "warning": boolToStr(warning),
                      "critical": boolToStr(critical),
                      "last_known_id": intToStr(last_known_id)
                    })
  querystring = "main?" & queryString 
  #debug(querystring)
  result = getDataFromApiJSON(self.cookie, self.url, BASE_LOG, queryString)
  debug (result)

proc getPeerLog*(self: Qb, last_known_id = -1): JsonNode =
  ## Get's the peer logs from the current Qt instance. Timeframe can be set by filling the `last_known_id` with an integer field different than -1.
  #TODO Replace choice fields
  var queryString = encodeQuery({
                      "last_known_id": intToStr(last_known_id)
                    })
  querystring = "peers?" & queryString 
  result = getDataFromApiJSON(self.cookie, self.url, BASE_LOG, queryString)
  debug (result)

proc getDefaultSavePath*(self: Qb): JsonNode = 
  ## Returns the default savepath of the Qbittorrent Instance.
  var res = getDataFromApi(self.cookie, self.url, BASE_APP, "defaultSavePath")
  var j = %*{"defaultsavepath": res}
  debug (j)
  result = j

proc getSyncMainData*(self: Qb, lastrid = 0): JsonNode = 
  ## Response ID. If not provided, rid=0 will be assumed. If the given rid is different from the one of last server reply, full_update will be true.
  #TODO Replace choice fields
  var queryString = encodeQuery({
                      "rid": intToStr(lastrid)
                    })
  querystring = "maindata?" & queryString 
  result = getDataFromApiJSON(self.cookie, self.url, BASE_SYNC, queryString)
  debug (result)

proc getGlobalTransferData*(self: Qb): JsonNode =
  ##Get global transfer info, like you usually see in the client's statusbar.
  result = getDataFromApiJSON(self.cookie, self.url, BASE_TRANSFER, "info")
  debug (result)

proc isSpeedLimitMode*(self: Qb): JsonNode =
  ## Returns true if speedlimit mode is activated, otherwise it returns false.
  var res = getDataFromApi(self.cookie, self.url, BASE_TRANSFER, "speedLimitsMode")
  if res == "1": 
      result = %*{"speedlimitmode": true}
  else:
      result = %*{"speedlimitmode": false}
  debug (result)

proc toggleSpeedLimitMode*(self: Qb): JsonNode = 
  var res = getDataFromApi(self.cookie, self.url, BASE_TRANSFER, "toggleSpeedLimitsMode")
  if res != "Error":
    result = %*{"toggled_speed_limit": true}
  else:
      result = %*{"toggled_speed_limit": false}
  debug(result)

proc getGlobalDownloadLimit*(self: var Qb): JsonNode =
  ## Gets the current global Download Limit. If 0 is returned, no download limit is set. Returns bytes/sec.
  var res = getDataFromApi(self.cookie, self.url, BASE_TRANSFER, "downloadLimit")
  result = %*{"globaldownloadlimit": res}
  debug(result)

proc setGlobalDownloadLimit*(self: Qb, limit:int = 0): JsonNode = 
  ## Sets the global Download Limit. Please note that the `limit` must be in bytes/sec.
  var queryString = encodeQuery({
                      "limit": intToStr(limit)
                    })
  querystring = "setDownloadLimit?" & queryString 
  var res = getDataFromApi(self.cookie, self.url, BASE_TRANSFER, queryString)
  result = %*{"setglobaldownloadlimit": res}
  debug(result)

proc getGlobalUploadLimit*(self: var Qb): JsonNode =
  ## Gets the current global Upload Limit. If 0 is returned, no download limit is set. Returns bytes/sec.
  var res = getDataFromApi(self.cookie, self.url, BASE_TRANSFER, "uploadLimit")
  result = %*{"globaluploadlimit": res}
  debug(result)

proc setGlobalUploadLimit*(self: Qb, limit:int = 0): JsonNode = 
  ## Sets the global Download Limit. Please note that the `limit` must be in bytes/sec.
  var queryString = encodeQuery({
                      "limit": intToStr(limit)
                    })
  querystring = "setUploadLimit?" & queryString 
  var res = getDataFromApi(self.cookie, self.url, BASE_TRANSFER, queryString)
  result = %*{"setglobaluploadlimit": res}
  debug(result)

proc getTorrents*(self: Qb, filter="all", category="", sort="", reverse=false, limit=0, offset=0, hashes=""): JsonNode =
  var querystring = "filter=" & filter
  if category.len != 0:
    querystring = querystring & "&category=" & category
  if sort.len != 0:
    querystring = querystring & "&sort=" & sort
  if reverse:
    querystring = querystring & "&reverse=true"
  if limit > 0:
    querystring = querystring & "&limit=" & intToStr(limit)
  if offset > 0:
    querystring = querystring & "&offset=" & intToStr(offset)
  if hashes.len > 0:
    querystring = querystring & "&hashes=" & (hashes)

  querystring = "info?" & queryString 
  result = getDataFromApiJSON(self.cookie, self.url, BASE_TORRENT, queryString)

proc getTorrentProperties*(self: Qb, hash:string): JsonNode =
  ## Returns the properties of the torrent provided via it's hash. You can get the torrent hash by calling getTorrents procedure.
  if hash == "":
    result = %*{"error": "No hash provided"}
  else:
    var querystring = "properties?hash=" & hash 
    result = getDataFromApiJSON(self.cookie, self.url, BASE_TORRENT, queryString)

proc getTorrentTrackers*(self: Qb, hash:string = ""): JsonNode =
  ## Returns tracker information of the torrent provided via it's hash. You can get the torrent hash by calling getTorrents procedure.
  if hash == "":
    result = %*{"error": "No hash provided"}
  else:
    var querystring = "trackers?hash=" & hash 
    result = getDataFromApiJSON(self.cookie, self.url, BASE_TORRENT, queryString)
  debug(result)

proc getTorrentWebSeeds*(self: Qb, hash:string = ""): JsonNode =
  ## Returns the WebSeeds of the torrent provided via it's hash. You can get the torrent hash by calling getTorrents procedure.
  if hash == "":
    result = %*{"error": "No hash provided"}
  else:
    var querystring = "webseeds?hash=" & hash 
    result = getDataFromApiJSON(self.cookie, self.url, BASE_TORRENT, queryString)
  debug(result)

proc getTorrentPiecesState*(self: Qb, hash:string = ""): JsonNode =
  ## Returns the States of the pieces of the torrent provided via it's hash. You can get the torrent hash by calling getTorrents procedure.
  ## - 0	Not downloaded yet
  ## - 1	Now downloading
  ## - 2	Already downloaded
  if hash == "":
    result = %*{"error": "No hash provided"}
  else:
    var querystring = "pieceStates?hash=" & hash 
    result = getDataFromApiJSON(self.cookie, self.url, BASE_TORRENT, queryString)
  debug(result)

proc getTorrentPiecesHashes*(self: Qb, hash:string = ""): JsonNode =
  ## Returns the hashes of the pieces of the torrent provided via it's hash. You can get the torrent hash by calling getTorrents procedure.
  if hash == "":
    result = %*{"error": "No hash provided"}
  else:
    var querystring = "pieceHashes?hash=" & hash 
    result = getDataFromApiJSON(self.cookie, self.url, BASE_TORRENT, queryString)
  debug(result)

proc setTorrentsPaused*(self: Qb, hashes:seq[string]): JsonNode = 
  ## Pauses the download/upload of torrents with the provided hashes. Requires knowing the torrents hashes. You can get it from getTorrents procedure.
  var h:string
  if hashes.len == 0:
      result = %*{"error": "No hashes provided"}
  else:
    h = hashesToStr(hashes)
    var querystring = "pause?hashes=" & h 
    result = getDataFromApiJSON(self.cookie, self.url, BASE_TORRENT, queryString)
  debug(result)

proc setTorrentsResumed*(self: Qb, hashes:seq[string]): JsonNode = 
  ## Resumes the download/upload of torrents with the provided hashes. Requires knowing the torrents hashes. You can get it from getTorrents procedure.
  var h:string
  if hashes.len == 0:
      result = %*{"error": "No hashes provided"}
  else:
    h = hashesToStr(hashes)
    var querystring = "resume?hashes=" & h 
    result = getDataFromApiJSON(self.cookie, self.url, BASE_TORRENT, queryString)
  debug(result)

proc getTorrentFiles*(self: Qb, hash:string = ""): JsonNode =
  ## Returns a list of the files included in the torrent with the provided hash.
  if hash == "":
    result = %*{"error": "No hash provided"}
  else:
    var querystring = "files?hash=" & hash 
    result = getDataFromApiJSON(self.cookie, self.url, BASE_TORRENT, queryString)
  debug(result)

proc deleteTorrents*(self: Qb, hashes:seq[string], deleteFiles=false): JsonNode =
  ## Deletes the torrents with the provided hashes. Requires knowing the torrents hashes. You can get it from getTorrents procedure. if deleteFiles is set to true, the physical files in the download path will be deleted.
  var h:string
  if hashes.len == 0:
      result = %*{"error": "No hashes provided"}
  else:
    h = hashesToStr(hashes)
    var querystring = "delete?hashes=" & h & "&deleteFiles=" & boolToStr(deleteFiles)
    result = getDataFromApiJSON(self.cookie, self.url, BASE_TORRENT, queryString)
  debug(result)

proc torrentsRecheck*(self: Qb, hashes:seq[string]): JsonNode = 
  ## Rechecks the torrents with the provided hashes. Requires knowing the torrents hashes. You can get it from getTorrents procedure.
  var h:string
  if hashes.len == 0:
      result = %*{"error": "No hashes provided"}
  else:
    h = hashesToStr(hashes)
    var querystring = "recheck?hashes=" & h 
    result = getDataFromApiJSON(self.cookie, self.url, BASE_TORRENT, queryString)
  debug(result)

proc torrentsIncreasePriority*(self: Qb, hashes:seq[string]): JsonNode = 
  ## Increases the priority of torrents with the provided hashes. Requires knowing the torrents hashes. You can get it from getTorrents procedure.
  var h:string
  if hashes.len == 0:
      result = %*{"error": "No hashes provided"}
  else:
    h = hashesToStr(hashes)
    var querystring = "increasePrio?hashes=" & h 
    result = getDataFromApiJSON(self.cookie, self.url, BASE_TORRENT, queryString)
  debug(result)

proc torrentsReannounce*(self: Qb, hashes:seq[string]): JsonNode = 
  ## Resumes the download/upload of torrents with the provided hashes. Requires knowing the torrents hashes. You can get it from getTorrents procedure.
  var h:string
  if hashes.len == 0:
      result = %*{"error": "No hashes provided"}
  else:
    h = hashesToStr(hashes)
    var querystring = "reannounce?hashes=" & h 
    result = getDataFromApiJSON(self.cookie, self.url, BASE_TORRENT, queryString)
  debug(result)


when isMainModule:
  var conn = initQb("http://192.168.42.167:8080", "admin", "adminadmin")
  discard conn.login()
  assert conn.connected == true
  discard conn.logout()
  assert conn.connected == false

## TODOS
## -----
## ::
##  proc postPreferences
##  proc banPeers
##  proc getTorrents, hashes
##  proc addTorrent
##  proc addTrackerToTorrent
##  proc editTracker
##  proc removeTrackerFromTorrent
##  proc adPeersToTorrent
##  proc torrentsDecreasePriority
##  proc torrentsMaximizePriority
##  proc torrentsMinimalPriority
##  proc torrentFilePriorities
##  proc getTorrentDownloadLimit
##  proc setTorrentDownloadLimit
##  proc setTorrentShareLimit
##  proc getTorrentUploadLimit
##  proc setTorrentUploadLimit
##  proc setTorrentLocation
##  proc setTorrentName
##  proc setTorrentCategory
##  proc getCategories
##  proc newCategory
##  proc editCategory
##  proc removeCategories
##  proc addTorrentTags
##  proc deleteTorrentTags
##  proc getTags
##  proc newTag
##  proc deleteTags
##  proc setAutomaticTorrentManagement
##  proc toggleSequentialDownload
##  proc setFirstLastPriority
##  proc setTorrentForceStart
##  proc setTorrentSupperSeeding
##  proc renameFile
##  ALL RSS methods
##  ALL search methods
##  Renaming the procedures consequently
## 
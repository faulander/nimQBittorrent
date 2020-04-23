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
  logging,
  macros
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

type
  Qb* = object
    cookie: string
    url: string
    connected: bool 
    username: string
    password: string
    referer: string
  
  Preferences* = object
    locale: string
    create_subfolder_enabled: bool
    start_paused_enabled: bool
    auto_delete_mode: int
    preallocate_all: bool
    incomplete_files_ext: bool
    auto_tmm_enabled: bool
    torrent_changed_tmm_enabled: bool
    save_path_changed_tmm_enabled: bool
    category_changed_tmm_enabled: bool
    save_path: string
    temp_path_enabled: bool
    temp_path: string
    scan_dirs: seq[string]
    export_dir: string
    export_dir_fin: string
    mail_notification_enabled: bool
    mail_notification_sender: string
    mail_notification_email: string
    mail_notification_smtp: string
    mail_notification_ssl_enabled: bool
    mail_notification_auth_enabled: bool
    mail_notification_username: string
    mail_notification_password: string
    autorun_enabled: bool
    autorun_program: string
    queueing_enabled: bool
    max_active_downloads: int
    max_active_torrents: int
    max_active_uploads: int
    dont_count_slow_torrents: bool
    slow_torrent_dl_rate_threshold: int
    slow_torrent_ul_rate_threshold: int
    slow_torrent_inactive_timer: int
    max_ratio_enabled: bool
    max_ratio: float
    max_ratio_act: bool
    listen_port: int
    upnp: bool
    random_port: bool
    dl_limit: int
    up_limit: int
    max_connec: int
    max_connec_per_torrent: int
    max_uploads: int
    max_uploads_per_torrent: int
    stop_tracker_timeout: int
    piece_extent_affinity: bool
    enable_utp: bool
    limit_utp_rate: bool
    limit_tcp_overhead: bool
    limit_lan_peers: bool
    alt_dl_limit: int
    alt_up_limit: int
    scheduler_enabled: bool
    schedule_from_hour: int
    schedule_from_min: int
    schedule_to_hour: int
    schedule_to_min: int
    scheduler_days: int
    dht: bool
    dhtSameAsBT: bool
    dht_port: int
    pex: bool
    lsd: bool
    encryption: int
    anonymous_mode: bool
    proxy_type: int
    proxy_ip: string
    proxy_port: int
    proxy_peer_connections: bool
    force_proxy: bool
    proxy_auth_enabled: bool
    proxy_username: string
    proxy_password: string
    ip_filter_enabled: bool
    ip_filter_path: string
    ip_filter_trackers: bool
    web_ui_domain_list: string
    web_ui_address: string
    web_ui_port: int
    web_ui_upnp: bool
    web_ui_username: string
    web_ui_password: string
    web_ui_csrf_protection_enabled: bool
    web_ui_clickjacking_protection_enabled: bool
    web_ui_secure_cookie_enabled: bool
    web_ui_max_auth_fail_count: int
    web_ui_ban_duration: int
    bypass_local_auth: bool
    bypass_auth_subnet_whitelist_enabled: bool
    bypass_auth_subnet_whitelist: string
    alternative_webui_enabled: bool
    alternative_webui_path: string
    use_https: bool
    ssl_key: string
    ssl_cert: string
    dyndns_enabled: bool
    dyndns_service: int
    dyndns_username: string
    dyndns_password: string
    dyndns_domain: string
    rss_refresh_interval: int
    rss_max_articles_per_feed: int
    rss_processing_enabled: bool
    rss_auto_downloading_enabled: bool

  HttpHeaders* = ref object
    table*: TableRef[string, seq[string]]

macro getFields(obj: typed): seq[string] =
  var fields: seq[string]
  for field in obj.getImpl[2][2]:
    fields.add $field[0]
  newLit fields

var consoleLog = newConsoleLogger(fmtStr="[$datetime] - $levelname - ", levelThreshold=lvlDebug)
addHandler(consoleLog)

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
  let finalUrl = url & base & meth & querystring
  debug("Proc: getDataFromApi, URL: ", finalUrl, ", Method: ", meth)
  let response {.inject.} = client.request(finalUrl, httpMethod = postorget)
  

proc getDataFromApi(cookie: string, url:string, base:string, meth:string, querystring = "", postorget = HttpGet): JsonNode =  
  getData()
  if response.status == "200 OK":
    try: 
      result = parseJson(response.body)
    except:
      result = %*{meth: response.body}
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
  result = getDataFromApi(self.cookie, self.url, BASE_APP, "version")
  debug (result)

proc getWebAPIVersion*(self: Qb): JsonNode = 
  ## returns the version of the QB API
  result = getDataFromApi(self.cookie, self.url, BASE_APP, "webapiVersion")
  debug (result)
 
proc getBuildInfo*(self: Qb): JsonNode = 
  ## Returns a JSON of the build information of QBittorrents libraries
  result = getDataFromApi(self.cookie, self.url, BASE_APP, "buildInfo")
  debug (result)

proc getPreferences*(self: Qb): JsonNode = 
  ## Returns all preferences of the QBittorrent Instance.
  #TODO Replace choice fields
  result = getDataFromApi(self.cookie, self.url, BASE_APP, "preferences")
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
  querystring = "?" & queryString 
  #debug(querystring)
  result = getDataFromApi(self.cookie, self.url, BASE_LOG, "main", queryString)
  debug (result)

proc getPeerLog*(self: Qb, last_known_id = -1): JsonNode =
  ## Get's the peer logs from the current Qt instance. Timeframe can be set by filling the `last_known_id` with an integer field different than -1.
  var queryString = "?last_known_id="  & intToStr(last_known_id)
  result = getDataFromApi(self.cookie, self.url, BASE_LOG, "peers", queryString)
  debug (result)

proc getDefaultSavePath*(self: Qb): JsonNode = 
  ## Returns the default savepath of the Qbittorrent Instance.
  result = getDataFromApi(self.cookie, self.url, BASE_APP, "defaultSavePath")
  debug (result)

proc getSyncMainData*(self: Qb, lastrid = 0): JsonNode = 
  ## If no lastrid is provided, lastrid 0 will be assumed. If the given rid is different from the one of last server reply, full_update will be true.
  var queryString = "?rid="  & intToStr(lastrid)
  result = getDataFromApi(self.cookie, self.url, BASE_LOG, "maindata", queryString)
  debug (result)

proc getGlobalTransferData*(self: Qb): JsonNode =
  ##Get global transfer info, like you usually see in the client's statusbar.
  result = getDataFromApi(self.cookie, self.url, BASE_TRANSFER, "info")
  debug (result)

proc isSpeedLimitMode*(self: Qb): JsonNode =
  ## Returns true if speedlimit mode is activated, otherwise it returns false.
  result = getDataFromApi(self.cookie, self.url, BASE_TRANSFER, "speedLimitsMode")
  debug (result)

proc toggleSpeedLimitMode*(self: Qb): JsonNode = 
  ## Toggles the SpeedLimit switch, true = false and false = true
  result = getDataFromApi(self.cookie, self.url, BASE_TRANSFER, "toggleSpeedLimitsMode")
  debug(result)

proc getGlobalDownloadLimit*(self: var Qb): JsonNode =
  ## Gets the current global Download Limit. If 0 is returned, no download limit is set. Returns bytes/sec.
  result = getDataFromApi(self.cookie, self.url, BASE_TRANSFER, "downloadLimit")
  debug (result)

proc setGlobalDownloadLimit*(self: Qb, limit:int = 0): JsonNode = 
  ## Sets the global Download Limit. Please note that the `limit` must be in bytes/sec.
  var querystring = "?limit="  & intToStr(limit)
  result = getDataFromApi(self.cookie, self.url, BASE_LOG, "limit", querystring)
  debug(result)

proc getGlobalUploadLimit*(self: var Qb): JsonNode =
  ## Gets the current global Upload Limit. If 0 is returned, no download limit is set. Returns bytes/sec.
  result = getDataFromApi(self.cookie, self.url, BASE_TRANSFER, "uploadLimit")
  debug(result)

proc setGlobalUploadLimit*(self: Qb, limit:int = 0): JsonNode = 
  ## Sets the global Download Limit. Please note that the `limit` must be in bytes/sec.
  var querystring = "?setUploadLimit=" & intToStr(limit)
  result = getDataFromApi(self.cookie, self.url, BASE_TRANSFER, "limit", querystring)
  debug(result)

proc getTorrents*(self: Qb, filter="all", category="", sort="", reverse=false, limit=0, offset=0, hashes:seq[string] = @[]): JsonNode =
  ## Gets a list of Torrents
  var querystring = "?filter=" & filter
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
    querystring = querystring & "&hashes=" & hashesToStr(hashes)

  result = getDataFromApi(self.cookie, self.url, BASE_TORRENT, "info", queryString)

proc getTorrentProperties*(self: Qb, hash:string): JsonNode =
  ## Returns the properties of the torrent provided via it's hash. You can get the torrent hash by calling getTorrents procedure.
  if hash == "":
    result = %*{"error": "No hash provided"}
  else:
    var querystring = "?hash=" & hash 
    result = getDataFromApi(self.cookie, self.url, BASE_TORRENT, "properties", queryString)

proc getTorrentTrackers*(self: Qb, hash:string = ""): JsonNode =
  ## Returns tracker information of the torrent provided via it's hash. You can get the torrent hash by calling getTorrents procedure.
  if hash == "":
    result = %*{"error": "No hash provided"}
  else:
    var querystring = "?hash=" & hash 
    result = getDataFromApi(self.cookie, self.url, BASE_TORRENT, "trackers", queryString)
  debug(result)

proc getTorrentWebSeeds*(self: Qb, hash:string = ""): JsonNode =
  ## Returns the WebSeeds of the torrent provided via it's hash. You can get the torrent hash by calling getTorrents procedure.
  if hash == "":
    result = %*{"error": "No hash provided"}
  else:
    var querystring = "?hash=" & hash 
    result = getDataFromApi(self.cookie, self.url, BASE_TORRENT, "webseeds", queryString)
  debug(result)

proc getTorrentPiecesState*(self: Qb, hash:string = ""): JsonNode =
  ## Returns the States of the pieces of the torrent provided via it's hash. You can get the torrent hash by calling getTorrents procedure.
  ## - 0	Not downloaded yet
  ## - 1	Now downloading
  ## - 2	Already downloaded
  if hash == "":
    result = %*{"error": "No hash provided"}
  else:
    var querystring = "?hash=" & hash 
    result = getDataFromApi(self.cookie, self.url, BASE_TORRENT, "pieceStates", queryString)
  debug(result)

proc getTorrentPiecesHashes*(self: Qb, hash:string = ""): JsonNode =
  ## Returns the hashes of the pieces of the torrent provided via it's hash. You can get the torrent hash by calling getTorrents procedure.
  if hash == "":
    result = %*{"error": "No hash provided"}
  else:
    var querystring = "?hash=" & hash 
    result = getDataFromApi(self.cookie, self.url, BASE_TORRENT, "pieceHashes", queryString)
  debug(result)

proc setTorrentsPaused*(self: Qb, hashes:seq[string]): JsonNode = 
  ## Pauses the download/upload of torrents with the provided hashes. Requires knowing the torrents hashes. You can get it from getTorrents procedure.
  var h:string
  if hashes.len == 0:
      result = %*{"error": "No hashes provided"}
  else:
    h = hashesToStr(hashes)
    var querystring = "?hashes=" & h 
    result = getDataFromApi(self.cookie, self.url, BASE_TORRENT, "pause", queryString)
  debug(result)

proc setTorrentsResumed*(self: Qb, hashes:seq[string]): JsonNode = 
  ## Resumes the download/upload of torrents with the provided hashes. Requires knowing the torrents hashes. You can get it from getTorrents procedure.
  var h:string
  if hashes.len == 0:
      result = %*{"error": "No hashes provided"}
  else:
    h = hashesToStr(hashes)
    var querystring = "?hashes=" & h 
    result = getDataFromApi(self.cookie, self.url, BASE_TORRENT, "resume", queryString)
  debug(result)

proc getTorrentFiles*(self: Qb, hash:string = ""): JsonNode =
  ## Returns a list of the files included in the torrent with the provided hash.
  if hash == "":
    result = %*{"error": "No hash provided"}
  else:
    var querystring = "?hash=" & hash 
    result = getDataFromApi(self.cookie, self.url, BASE_TORRENT, "files", queryString)
  debug(result)

proc deleteTorrents*(self: Qb, hashes:seq[string], deleteFiles=false): JsonNode =
  ## Deletes the torrents with the provided hashes. Requires knowing the torrents hashes. You can get it from getTorrents procedure. if deleteFiles is set to true, the physical files in the download path will be deleted.
  var h:string
  if hashes.len == 0:
      result = %*{"error": "No hashes provided"}
  else:
    h = hashesToStr(hashes)
    var querystring = "?hashes=" & h & "&deleteFiles=" & boolToStr(deleteFiles)
    result = getDataFromApi(self.cookie, self.url, BASE_TORRENT, "delete", queryString)
  debug(result)

proc torrentsRecheck*(self: Qb, hashes:seq[string]): JsonNode = 
  ## Rechecks the torrents with the provided hashes. Requires knowing the torrents hashes. You can get it from getTorrents procedure.
  var h:string
  if hashes.len == 0:
      result = %*{"error": "No hashes provided"}
  else:
    h = hashesToStr(hashes)
    var querystring = "?hashes=" & h 
    result = getDataFromApi(self.cookie, self.url, BASE_TORRENT, "recheck", queryString)
  debug(result)

proc torrentsIncreasePriority*(self: Qb, hashes:seq[string]): JsonNode = 
  ## Increases the priority of torrents with the provided hashes. Requires knowing the torrents hashes. You can get it from getTorrents procedure.
  var h:string
  if hashes.len == 0:
      result = %*{"error": "No hashes provided"}
  else:
    h = hashesToStr(hashes)
    var querystring = "?hashes=" & h 
    result = getDataFromApi(self.cookie, self.url, BASE_TORRENT, "increasePrio", queryString)
  debug(result)

proc torrentsReannounce*(self: Qb, hashes:seq[string]): JsonNode = 
  ## Resumes the download/upload of torrents with the provided hashes. Requires knowing the torrents hashes. You can get it from getTorrents procedure.
  var h:string
  if hashes.len == 0:
      result = %*{"error": "No hashes provided"}
  else:
    h = hashesToStr(hashes)
    var querystring = "?hashes=" & h 
    result = getDataFromApi(self.cookie, self.url, BASE_TORRENT, "reannounce", queryString)
  debug(result)

proc banPeers*(self: Qb, peers:seq[string]): JsonNode =
  var h:string
  if peers.len == 0:
      result = %*{"error": "No peers provided"}
  else:
    h = hashesToStr(peers)
    var querystring = "?peers=" & h 
    result = getDataFromApi(self.cookie, self.url, BASE_TORRENT, "banPeers", queryString)
  debug(result)

proc deleteTorrents*(self: Qb, hashes:seq[string], delFiles = false): JsonNode =
  var h:string
  var querystring:string
  if hashes.len == 0:
      result = %*{"error": "No hashes provided"}
  else:
    h = hashesToStr(hashes)
    querystring = "?hashes=" & h 
    if delFiles:
      querystring &= "&deleteFiles=true"
    result = getDataFromApi(self.cookie, self.url, BASE_TORRENT, "delete", queryString)
  debug(result)


when isMainModule:
  var conn = initQb("http://192.168.42.167:8080", "admin", "adminadmin")
  discard conn.login()
  assert conn.connected == true
  echo conn.getTorrents()
  discard conn.logout()
  assert conn.connected == false

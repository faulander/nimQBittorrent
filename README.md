# nimQt - a wrapper for the QBittorrent Web-API

## QUICK EXAMPLE
```nim
import nimqt
let connection = initQb("http://127.0.0.1:8080", "admin", "adminadmin")
conn.login()
if conn.connected:
  var torrents = conn.getTorrents()
  for torrent in torrents:
    echo getTorrentFiles(torrent["hash"])
```
## METHODS

* initQb
proc initQb(url: string; username: string; password: string): Qb {.raises: [], tags: [].}
* login
proc login(self: var Qb): bool {.raises: [OSError, SslError, ValueError, Exception,
                                    HttpRequestError, IOError, Defect,
                                    TimeoutError, ProtocolError, KeyError], tags: [
    ReadIOEffect, WriteIOEffect, TimeEffect, RootEffect].}
* logout
proc logout(self: var Qb): bool {.raises: [KeyError, ValueError, OSError,
                                     HttpRequestError, SslError, IOError, Defect,
                                     Exception, TimeoutError, ProtocolError], tags: [
    ReadIOEffect, WriteIOEffect, TimeEffect, RootEffect].}
* getVersion
proc getVersion(self: Qb): JsonNode {.raises: [KeyError, Exception, ValueError, OSError,
    HttpRequestError, SslError, IOError, Defect, TimeoutError, ProtocolError], tags: [
    RootEffect, ReadIOEffect, WriteIOEffect, TimeEffect].}
* getWebAPIVersion
proc getWebAPIVersion(self: Qb): JsonNode {.raises: [KeyError, Exception, ValueError,
    OSError, HttpRequestError, SslError, IOError, Defect, TimeoutError, ProtocolError], tags: [
    RootEffect, ReadIOEffect, WriteIOEffect, TimeEffect].}
* getBuildInfo
proc getBuildInfo(self: Qb): JsonNode {.raises: [KeyError, Exception, ValueError,
    OSError, HttpRequestError, SslError, IOError, Defect, TimeoutError, ProtocolError], tags: [
    RootEffect, ReadIOEffect, WriteIOEffect, TimeEffect].}
* getPreferences
proc getPreferences(self: Qb): JsonNode {.raises: [KeyError, Exception, ValueError,
    OSError, HttpRequestError, SslError, IOError, Defect, TimeoutError, ProtocolError], tags: [
    RootEffect, ReadIOEffect, WriteIOEffect, TimeEffect].}
* getMainLog
proc getMainLog(self: Qb; normal = false; info = false; warning = true; critical = true;
               last_known_id = -1): JsonNode {.raises: [KeyError, Exception,
    ValueError, OSError, HttpRequestError, SslError, IOError, Defect, TimeoutError,
    ProtocolError], tags: [RootEffect, ReadIOEffect, WriteIOEffect, TimeEffect].}
* getPeerLog
proc getPeerLog(self: Qb; last_known_id = -1): JsonNode {.raises: [KeyError, Exception,
    ValueError, OSError, HttpRequestError, SslError, IOError, Defect, TimeoutError,
    ProtocolError], tags: [RootEffect, ReadIOEffect, WriteIOEffect, TimeEffect].}
* getDefaultSavePath
proc getDefaultSavePath(self: Qb): JsonNode {.raises: [KeyError, Exception, ValueError,
    OSError, HttpRequestError, SslError, IOError, Defect, TimeoutError, ProtocolError],
    tags: [RootEffect, ReadIOEffect, WriteIOEffect, TimeEffect].}
* getSyncMainData
proc getSyncMainData(self: Qb; lastrid = 0): JsonNode {.raises: [KeyError, Exception,
    ValueError, OSError, HttpRequestError, SslError, IOError, Defect, TimeoutError,
    ProtocolError], tags: [RootEffect, ReadIOEffect, WriteIOEffect, TimeEffect].}
* getGlobalTransferData
proc getGlobalTransferData(self: Qb): JsonNode {.raises: [KeyError, Exception,
    ValueError, OSError, HttpRequestError, SslError, IOError, Defect, TimeoutError,
    ProtocolError], tags: [RootEffect, ReadIOEffect, WriteIOEffect, TimeEffect].}
* isSpeedLimitMode
proc isSpeedLimitMode(self: Qb): JsonNode {.raises: [KeyError, Exception, ValueError,
    OSError, HttpRequestError, SslError, IOError, Defect, TimeoutError, ProtocolError], tags: [
    RootEffect, ReadIOEffect, WriteIOEffect, TimeEffect].}
* toggleSpeedLimitMode
proc toggleSpeedLimitMode(self: Qb): JsonNode {.raises: [KeyError, Exception,
    ValueError, OSError, HttpRequestError, SslError, IOError, Defect, TimeoutError,
    ProtocolError], tags: [RootEffect, ReadIOEffect, WriteIOEffect, TimeEffect].}
* getGlobalDownloadLimit
proc getGlobalDownloadLimit(self: var Qb): JsonNode {.raises: [KeyError, Exception,
    ValueError, OSError, HttpRequestError, SslError, IOError, Defect, TimeoutError,
    ProtocolError], tags: [RootEffect, ReadIOEffect, WriteIOEffect, TimeEffect].}
* setGlobalDownloadLimit
proc setGlobalDownloadLimit(self: Qb; limit: int = 0): JsonNode {.raises: [KeyError,
    Exception, ValueError, OSError, HttpRequestError, SslError, IOError, Defect,
    TimeoutError, ProtocolError],
    tags: [RootEffect, ReadIOEffect, WriteIOEffect, TimeEffect].}
* getGlobalUploadLimit
proc getGlobalUploadLimit(self: var Qb): JsonNode {.raises: [KeyError, Exception,
    ValueError, OSError, HttpRequestError, SslError, IOError, Defect, TimeoutError,
    ProtocolError], tags: [RootEffect, ReadIOEffect, WriteIOEffect, TimeEffect].}
* setGlobalUploadLimit
proc setGlobalUploadLimit(self: Qb; limit: int = 0): JsonNode {.raises: [KeyError,
    Exception, ValueError, OSError, HttpRequestError, SslError, IOError, Defect,
    TimeoutError, ProtocolError],
    tags: [RootEffect, ReadIOEffect, WriteIOEffect, TimeEffect].}
* getTorrents
proc getTorrents(self: Qb; filter = "all"; category = ""; sort = ""; reverse = false;
                limit = 0; offset = 0; hashes: seq[string] = @[]): JsonNode {.raises: [
    KeyError, Exception, ValueError, OSError, HttpRequestError, SslError, IOError,
    Defect, TimeoutError, ProtocolError],
    tags: [RootEffect, ReadIOEffect, WriteIOEffect, TimeEffect].}
* getTorrentProperties
proc getTorrentProperties(self: Qb; hash: string): JsonNode {.raises: [KeyError,
    Exception, ValueError, OSError, HttpRequestError, SslError, IOError, Defect,
    TimeoutError, ProtocolError],
    tags: [RootEffect, ReadIOEffect, WriteIOEffect, TimeEffect].}
* getTorrentTrackers
proc getTorrentTrackers(self: Qb; hash: string = ""): JsonNode {.raises: [KeyError,
    Exception, ValueError, OSError, HttpRequestError, SslError, IOError, Defect,
    TimeoutError, ProtocolError],
    tags: [RootEffect, ReadIOEffect, WriteIOEffect, TimeEffect].}
* getTorrentWebSeeds
proc getTorrentWebSeeds(self: Qb; hash: string = ""): JsonNode {.raises: [KeyError,
    Exception, ValueError, OSError, HttpRequestError, SslError, IOError, Defect,
    TimeoutError, ProtocolError],
    tags: [RootEffect, ReadIOEffect, WriteIOEffect, TimeEffect].}
* getTorrentPiecesState
proc getTorrentPiecesState(self: Qb; hash: string = ""): JsonNode {.raises: [KeyError,
    Exception, ValueError, OSError, HttpRequestError, SslError, IOError, Defect,
    TimeoutError, ProtocolError],
    tags: [RootEffect, ReadIOEffect, WriteIOEffect, TimeEffect].}
* getTorrentPiecesHashes
proc getTorrentPiecesHashes(self: Qb; hash: string = ""): JsonNode {.raises: [KeyError,
    Exception, ValueError, OSError, HttpRequestError, SslError, IOError, Defect,
    TimeoutError, ProtocolError],
    tags: [RootEffect, ReadIOEffect, WriteIOEffect, TimeEffect].}
* setTorrentsPaused
proc setTorrentsPaused(self: Qb; hashes: seq[string]): JsonNode {.raises: [KeyError,
    Exception, ValueError, OSError, HttpRequestError, SslError, IOError, Defect,
    TimeoutError, ProtocolError],
    tags: [RootEffect, ReadIOEffect, WriteIOEffect, TimeEffect].}
* setTorrentsResumed
proc setTorrentsResumed(self: Qb; hashes: seq[string]): JsonNode {.raises: [KeyError,
    Exception, ValueError, OSError, HttpRequestError, SslError, IOError, Defect,
    TimeoutError, ProtocolError],
    tags: [RootEffect, ReadIOEffect, WriteIOEffect, TimeEffect].}
* getTorrentFiles
proc getTorrentFiles(self: Qb; hash: string = ""): JsonNode {.raises: [KeyError,
    Exception, ValueError, OSError, HttpRequestError, SslError, IOError, Defect,
    TimeoutError, ProtocolError],
    tags: [RootEffect, ReadIOEffect, WriteIOEffect, TimeEffect].}
* deleteTorrents
proc deleteTorrents(self: Qb; hashes: seq[string]; deleteFiles = false): JsonNode {.raises: [
    KeyError, Exception, ValueError, OSError, HttpRequestError, SslError, IOError,
    Defect, TimeoutError, ProtocolError],
    tags: [RootEffect, ReadIOEffect, WriteIOEffect, TimeEffect].}
* torrentsRecheck
proc torrentsRecheck(self: Qb; hashes: seq[string]): JsonNode {.raises: [KeyError,
    Exception, ValueError, OSError, HttpRequestError, SslError, IOError, Defect,
    TimeoutError, ProtocolError],
    tags: [RootEffect, ReadIOEffect, WriteIOEffect, TimeEffect].}
* torrentsIncreasePriority
proc torrentsIncreasePriority(self: Qb; hashes: seq[string]): JsonNode {.raises: [
    KeyError, Exception, ValueError, OSError, HttpRequestError, SslError, IOError,
    Defect, TimeoutError, ProtocolError],
    tags: [RootEffect, ReadIOEffect, WriteIOEffect, TimeEffect].}
* torrentsReannounce
proc torrentsReannounce(self: Qb; hashes: seq[string]): JsonNode {.raises: [KeyError,
    Exception, ValueError, OSError, HttpRequestError, SslError, IOError, Defect,
    TimeoutError, ProtocolError],
    tags: [RootEffect, ReadIOEffect, WriteIOEffect, TimeEffect].}
* banPeers
proc banPeers(self: Qb; peers: seq[string]): JsonNode {.raises: [KeyError, Exception,
    ValueError, OSError, HttpRequestError, SslError, IOError, Defect, TimeoutError,
    ProtocolError], tags: [RootEffect, ReadIOEffect, WriteIOEffect, TimeEffect].}
* deleteTorrents
proc deleteTorrents(self: Qb; hashes: seq[string]; delFiles = false): JsonNode {.raises: [
    KeyError, Exception, ValueError, OSError, HttpRequestError, SslError, IOError,
    Defect, TimeoutError, ProtocolError],
    tags: [RootEffect, ReadIOEffect, WriteIOEffect, TimeEffect].}
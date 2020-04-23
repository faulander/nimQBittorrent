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

## **proc** initQb

Initializes a Session.

```nim
proc initQb(url: string; username: string; password: string): Qb
```

## **proc** login

tries to login with the credentials provided in initQb Logs into the QBittorrent WebAPI with the credentials provided in initQb.

```nim
proc login(self: var Qb): bool {.raises: [OSError, SslError, ValueError, Exception, HttpRequestError, IOError, Defect, TimeoutError, ProtocolError, KeyError], tags: [
 ReadIOEffect, WriteIOEffect, TimeEffect, RootEffect].}
```

## **proc** logout

Logs out of the current session

```nim
proc logout(self: var Qb): bool {.raises: [KeyError, ValueError, OSError, HttpRequestError, SslError, IOError, Defect, Exception, TimeoutError, ProtocolError], tags: [
 ReadIOEffect, WriteIOEffect, TimeEffect, RootEffect].}
```

## **proc** getVersion

returns the version of the QBittorrent client

```nim
proc getVersion(self: Qb): JsonNode {.raises: [KeyError, Exception, ValueError, OSError, HttpRequestError, SslError, IOError, Defect, TimeoutError, ProtocolError], tags: [
 RootEffect, ReadIOEffect, WriteIOEffect, TimeEffect].}
```

## **proc** getWebAPIVersion

returns the version of the QB API

```nim
proc getWebAPIVersion(self: Qb): JsonNode {.raises: [KeyError, Exception, ValueError, OSError, HttpRequestError, SslError, IOError, Defect, TimeoutError, ProtocolError], tags: [
 RootEffect, ReadIOEffect, WriteIOEffect, TimeEffect].}
```

## **proc** getBuildInfo

Returns a JSON of the build information of QBittorrents libraries

```nim
proc getBuildInfo(self: Qb): JsonNode {.raises: [KeyError, Exception, ValueError, OSError, HttpRequestError, SslError, IOError, Defect, TimeoutError, ProtocolError, JsonParsingError], tags: [RootEffect, ReadIOEffect, WriteIOEffect, TimeEffect].}
```

## **proc** getPreferences

Returns all preferences of the QBittorrent Instance.

```nim
proc getPreferences(self: Qb): JsonNode {.raises: [KeyError, Exception, ValueError, OSError, HttpRequestError, SslError, IOError, Defect, TimeoutError, ProtocolError, JsonParsingError], tags: [RootEffect, ReadIOEffect, WriteIOEffect, TimeEffect].}
```

## **proc** getMainLog

Get's the logs from the current Qt instance. The level can be set by enabling or disabling the loglevels. Timeframe can be set by filling the <tt class="docutils literal"><span class="pre">last_known_id</span></tt> with an integer field different than -1.

```nim
proc getMainLog(self: Qb; normal = false; info = false; warning = true; critical = true;
 last_known_id = -1): JsonNode {.raises: [KeyError, Exception, ValueError, OSError, HttpRequestError, SslError, IOError, Defect, TimeoutError, ProtocolError, JsonParsingError], tags: [RootEffect, ReadIOEffect, WriteIOEffect, TimeEffect].}
```

## **proc** getPeerLog

Get's the peer logs from the current Qt instance. Timeframe can be set by filling the <tt class="docutils literal"><span class="pre">last_known_id</span></tt> with an integer field different than -1.

```nim
proc getPeerLog(self: Qb; last_known_id = -1): JsonNode {.raises: [KeyError, Exception, ValueError, OSError, HttpRequestError, SslError, IOError, Defect, TimeoutError, ProtocolError, JsonParsingError], tags: [RootEffect, ReadIOEffect, WriteIOEffect, TimeEffect].}
```

## **proc** getDefaultSavePath

Returns the default savepath of the Qbittorrent Instance.

```nim
proc getDefaultSavePath(self: Qb): JsonNode {.raises: [KeyError, Exception, ValueError, OSError, HttpRequestError, SslError, IOError, Defect, TimeoutError, ProtocolError], tags: [RootEffect, ReadIOEffect, WriteIOEffect, TimeEffect].}
```

## **proc** getSyncMainData

Response ID. If not provided, rid=0 will be assumed. If the given rid is different from the one of last server reply, full_update will be true.

```nim
proc getSyncMainData(self: Qb; lastrid = 0): JsonNode {.raises: [KeyError, Exception, ValueError, OSError, HttpRequestError, SslError, IOError, Defect, TimeoutError, ProtocolError, JsonParsingError], tags: [RootEffect, ReadIOEffect, WriteIOEffect, TimeEffect].}
```

## **proc** getGlobalTransferData

Get global transfer info, like you usually see in the client's statusbar.

```nim
proc getGlobalTransferData(self: Qb): JsonNode {.raises: [KeyError, Exception, ValueError, OSError, HttpRequestError, SslError, IOError, Defect, TimeoutError, ProtocolError, JsonParsingError], tags: [RootEffect, ReadIOEffect, WriteIOEffect, TimeEffect].}
```

## **proc** isSpeedLimitMode

Returns true if speedlimit mode is activated, otherwise it returns false.

```nim
proc isSpeedLimitMode(self: Qb): JsonNode {.raises: [KeyError, Exception, ValueError, OSError, HttpRequestError, SslError, IOError, Defect, TimeoutError, ProtocolError], tags: [
 RootEffect, ReadIOEffect, WriteIOEffect, TimeEffect].}
```

## **proc** toggleSpeedLimitMode


```nim
proc toggleSpeedLimitMode(self: Qb): JsonNode {.raises: [KeyError, Exception, ValueError, OSError, HttpRequestError, SslError, IOError, Defect, TimeoutError, ProtocolError], tags: [RootEffect, ReadIOEffect, WriteIOEffect, TimeEffect].}
```

## **proc** getGlobalDownloadLimit

Gets the current global Download Limit. If 0 is returned, no download limit is set. Returns bytes/sec.

```nim
proc getGlobalDownloadLimit(self: var Qb): JsonNode {.raises: [KeyError, Exception, ValueError, OSError, HttpRequestError, SslError, IOError, Defect, TimeoutError, ProtocolError], tags: [RootEffect, ReadIOEffect, WriteIOEffect, TimeEffect].}
```

## **proc** setGlobalDownloadLimit

Sets the global Download Limit. Please note that the <tt class="docutils literal"><span class="pre">limit</span></tt> must be in bytes/sec.

```nim
proc setGlobalDownloadLimit(self: Qb; limit: int = 0): JsonNode {.raises: [KeyError, Exception, ValueError, OSError, HttpRequestError, SslError, IOError, Defect, TimeoutError, ProtocolError], tags: [RootEffect, ReadIOEffect, WriteIOEffect, TimeEffect].}
```

## **proc** getGlobalUploadLimit

Gets the current global Upload Limit. If 0 is returned, no download limit is set. Returns bytes/sec.

```nim
proc getGlobalUploadLimit(self: var Qb): JsonNode {.raises: [KeyError, Exception, ValueError, OSError, HttpRequestError, SslError, IOError, Defect, TimeoutError, ProtocolError], tags: [RootEffect, ReadIOEffect, WriteIOEffect, TimeEffect].}
```

## **proc** setGlobalUploadLimit

Sets the global Download Limit. Please note that the <tt class="docutils literal"><span class="pre">limit</span></tt> must be in bytes/sec.

```nim
proc setGlobalUploadLimit(self: Qb; limit: int = 0): JsonNode {.raises: [KeyError, Exception, ValueError, OSError, HttpRequestError, SslError, IOError, Defect, TimeoutError, ProtocolError], tags: [RootEffect, ReadIOEffect, WriteIOEffect, TimeEffect].}
```

## **proc** getTorrents

Gets a list of Torrents

```nim
proc getTorrents(self: Qb; filter = "all"; category = ""; sort = ""; reverse = false;
 limit = 0; offset = 0; hashes: seq[string]): JsonNode {.raises: [KeyError, Exception, ValueError, OSError, HttpRequestError, SslError, IOError, Defect, TimeoutError, ProtocolError, JsonParsingError], tags: [RootEffect, ReadIOEffect, WriteIOEffect, TimeEffect].}
```

## **proc** getTorrentProperties

Returns the properties of the torrent provided via it's hash. You can get the torrent hash by calling getTorrents procedure.

```nim
proc getTorrentProperties(self: Qb; hash: string): JsonNode {.raises: [KeyError, Exception, ValueError, OSError, HttpRequestError, SslError, IOError, Defect, TimeoutError, ProtocolError, JsonParsingError], tags: [RootEffect, ReadIOEffect, WriteIOEffect, TimeEffect].}
```

## **proc** getTorrentTrackers

Returns tracker information of the torrent provided via it's hash. You can get the torrent hash by calling getTorrents procedure.

```nim
proc getTorrentTrackers(self: Qb; hash: string = ""): JsonNode {.raises: [KeyError, Exception, ValueError, OSError, HttpRequestError, SslError, IOError, Defect, TimeoutError, ProtocolError, JsonParsingError], tags: [RootEffect, ReadIOEffect, WriteIOEffect, TimeEffect].}
```

## **proc** getTorrentWebSeeds

Returns the WebSeeds of the torrent provided via it's hash. You can get the torrent hash by calling getTorrents procedure.

```nim
proc getTorrentWebSeeds(self: Qb; hash: string = ""): JsonNode {.raises: [KeyError, Exception, ValueError, OSError, HttpRequestError, SslError, IOError, Defect, TimeoutError, ProtocolError, JsonParsingError], tags: [RootEffect, ReadIOEffect, WriteIOEffect, TimeEffect].}
```

## **proc** getTorrentPiecesState

Returns the States of the pieces of the torrent provided via it's hash. You can get the torrent hash by calling getTorrents procedure.
 * 0	Not downloaded yet
 * 1	Now downloading
 * 2	Already downloaded

```nim
proc getTorrentPiecesState(self: Qb; hash: string = ""): JsonNode {.raises: [KeyError, Exception, ValueError, OSError, HttpRequestError, SslError, IOError, Defect, TimeoutError, ProtocolError, JsonParsingError], tags: [RootEffect, ReadIOEffect, WriteIOEffect, TimeEffect].}
```

## **proc** getTorrentPiecesHashes

Returns the hashes of the pieces of the torrent provided via it's hash. You can get the torrent hash by calling getTorrents procedure.

```nim
proc getTorrentPiecesHashes(self: Qb; hash: string = ""): JsonNode {.raises: [KeyError, Exception, ValueError, OSError, HttpRequestError, SslError, IOError, Defect, TimeoutError, ProtocolError, JsonParsingError], tags: [RootEffect, ReadIOEffect, WriteIOEffect, TimeEffect].}
```

## **proc** setTorrentsPaused

Pauses the download/upload of torrents with the provided hashes. Requires knowing the torrents hashes. You can get it from getTorrents procedure.

```nim
proc setTorrentsPaused(self: Qb; hashes: seq[string]): JsonNode {.raises: [KeyError, Exception, ValueError, OSError, HttpRequestError, SslError, IOError, Defect, TimeoutError, ProtocolError, JsonParsingError], tags: [RootEffect, ReadIOEffect, WriteIOEffect, TimeEffect].}
```

## **proc** setTorrentsResumed

Resumes the download/upload of torrents with the provided hashes. Requires knowing the torrents hashes. You can get it from getTorrents procedure.

```nim
proc setTorrentsResumed(self: Qb; hashes: seq[string]): JsonNode {.raises: [KeyError, Exception, ValueError, OSError, HttpRequestError, SslError, IOError, Defect, TimeoutError, ProtocolError, JsonParsingError], tags: [RootEffect, ReadIOEffect, WriteIOEffect, TimeEffect].}
```

## **proc** getTorrentFiles

Returns a list of the files included in the torrent with the provided hash.

```nim
proc getTorrentFiles(self: Qb; hash: string = ""): JsonNode {.raises: [KeyError, Exception, ValueError, OSError, HttpRequestError, SslError, IOError, Defect, TimeoutError, ProtocolError, JsonParsingError], tags: [RootEffect, ReadIOEffect, WriteIOEffect, TimeEffect].}
```

## **proc** deleteTorrents

Deletes the torrents with the provided hashes. Requires knowing the torrents hashes. You can get it from getTorrents procedure. if deleteFiles is set to true, the physical files in the download path will be deleted.

```nim
proc deleteTorrents(self: Qb; hashes: seq[string]; deleteFiles = false): JsonNode {.raises: [
 KeyError, Exception, ValueError, OSError, HttpRequestError, SslError, IOError, Defect, TimeoutError, ProtocolError, JsonParsingError], tags: [RootEffect, ReadIOEffect, WriteIOEffect, TimeEffect].}
```

## **proc** torrentsRecheck

Rechecks the torrents with the provided hashes. Requires knowing the torrents hashes. You can get it from getTorrents procedure.

```nim
proc torrentsRecheck(self: Qb; hashes: seq[string]): JsonNode {.raises: [KeyError, Exception, ValueError, OSError, HttpRequestError, SslError, IOError, Defect, TimeoutError, ProtocolError, JsonParsingError], tags: [RootEffect, ReadIOEffect, WriteIOEffect, TimeEffect].}
```

## **proc** torrentsIncreasePriority

Increases the priority of torrents with the provided hashes. Requires knowing the torrents hashes. You can get it from getTorrents procedure.

```nim
proc torrentsIncreasePriority(self: Qb; hashes: seq[string]): JsonNode {.raises: [
 KeyError, Exception, ValueError, OSError, HttpRequestError, SslError, IOError, Defect, TimeoutError, ProtocolError, JsonParsingError], tags: [RootEffect, ReadIOEffect, WriteIOEffect, TimeEffect].}
```

## **proc** torrentsReannounce

Resumes the download/upload of torrents with the provided hashes. Requires knowing the torrents hashes. You can get it from getTorrents procedure.

```nim
proc torrentsReannounce(self: Qb; hashes: seq[string]): JsonNode {.raises: [KeyError, Exception, ValueError, OSError, HttpRequestError, SslError, IOError, Defect, TimeoutError, ProtocolError, JsonParsingError], tags: [RootEffect, ReadIOEffect, WriteIOEffect, TimeEffect].}
```

## **proc** banPeers


```nim
proc banPeers(self: Qb; peers: seq[string]): JsonNode {.raises: [KeyError, Exception, ValueError, OSError, HttpRequestError, SslError, IOError, Defect, TimeoutError, ProtocolError, JsonParsingError], tags: [RootEffect, ReadIOEffect, WriteIOEffect, TimeEffect].}
```

## **proc** deleteTorrents


```nim
proc deleteTorrents(self: Qb; hashes: seq[string]; delFiles = false): JsonNode {.raises: [
 KeyError, Exception, ValueError, OSError, HttpRequestError, SslError, IOError, Defect, TimeoutError, ProtocolError, JsonParsingError], tags: [RootEffect, ReadIOEffect, WriteIOEffect, TimeEffect].}
```

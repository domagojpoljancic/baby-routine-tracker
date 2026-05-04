import Toybox.Application;
import Toybox.Lang;
import Toybox.Time;

// Persistent, append-only feeding entry store backed by Application Storage.
// Intended to be storage-safe even across builds: store only primitives and arrays/dictionaries.
// entry["t"] is numeric: 1=Left, 2=Right, 3=Bottle, 4=Diaper.
class FeedingStore {

    var STORAGE_KEY = "feedings_v1";
    var GLANCE_RECENT_KEY = "glance_recent_v1";
    var RECENT_FEEDINGS_KEY = "recent_feedings_v1";
    var RECENT_DIAPERS_KEY = "recent_diapers_v1";
    var RECENT_CACHE_VERSION_KEY = "recent_cache_version_v1";
    var RECENT_CACHE_VERSION = 2;

    hidden static var _memList = null;
    hidden static var _memReady = false;

    function _readListFromStorage() {
        var list = Application.Storage.getValue(STORAGE_KEY);
        if (list == null) {
            _memList = [];
            _memReady = true;
            return _memList;
        }

        _memList = list;
        _memReady = true;
        return list;
    }

    function _cacheEntryEquals(a, b) {
        if (a == null || b == null) {
            return false;
        }

        return _safeEntryTimestamp(a) == _safeEntryTimestamp(b) &&
            _safeEntryTypeCode(a) == _safeEntryTypeCode(b);
    }

    function _appendNewestToCache(list, entry, maxCount, mode) {
        if (!_isValidEntryForRecent(entry) || !_entryMatchesRecentMode(entry, mode)) {
            return list;
        }

        if (list == null || !(list instanceof Array)) {
            return [entry];
        }

        var arr = list as Array;
        if (arr.size() > 0 && _cacheEntryEquals(arr[arr.size() - 1], entry)) {
            return list;
        }

        var newTs = _safeEntryTimestamp(entry);
        var out = [];
        var inserted = false;
        var i;
        for (i = 0; i < arr.size(); i += 1) {
            var e = arr[i];
            if (!inserted && _safeEntryTimestamp(e) != null && newTs < _safeEntryTimestamp(e)) {
                out.add(entry);
                inserted = true;
            }
            out.add(e);
        }

        if (!inserted) {
            out.add(entry);
        }

        while (out.size() > maxCount) {
            out = out.slice(1, out.size());
        }

        return out;
    }

    function _updateRecentCachesAfterAppend(entry) {
        var glance = Application.Storage.getValue(GLANCE_RECENT_KEY);
        if (glance == null || !(glance instanceof Array)) {
            glance = [];
        }
        glance = _appendNewestToCache(glance, entry, 2, 0);

        var feedings = Application.Storage.getValue(RECENT_FEEDINGS_KEY);
        if (feedings == null || !(feedings instanceof Array)) {
            feedings = [];
        }
        feedings = _appendNewestToCache(feedings, entry, 3, 1);

        var diapers = Application.Storage.getValue(RECENT_DIAPERS_KEY);
        if (diapers == null || !(diapers instanceof Array)) {
            diapers = [];
        }
        diapers = _appendNewestToCache(diapers, entry, 3, 2);

        _setRecentCache(GLANCE_RECENT_KEY, glance);
        _setRecentCache(RECENT_FEEDINGS_KEY, feedings);
        _setRecentCache(RECENT_DIAPERS_KEY, diapers);
        _setRecentCache(RECENT_CACHE_VERSION_KEY, RECENT_CACHE_VERSION);
    }

    function load(ensureCaches) {
        var list = null;
        if (!ensureCaches && _memReady && _memList != null) {
            list = _memList;
        } else {
            list = _readListFromStorage();
        }

        if (list == null) {
            _storeRecentCaches([]);
            _memList = [];
            _memReady = true;
            return [];
        }

        if (ensureCaches) {
            _ensureRecentCaches(list);
        }
        return list;
    }

    function loadRecentFeedings() {
        return _loadRecentCache(RECENT_FEEDINGS_KEY);
    }

    function loadRecentDiapers() {
        return _loadRecentCache(RECENT_DIAPERS_KEY);
    }

    function append(typeCode) {
        appendAt(typeCode, Time.now().value());
    }

    function appendAt(typeCode, timestamp) {
        if (!_isValidTypeCode(typeCode) || !_isValidTimestamp(timestamp)) {
            return false;
        }

        var list = load(false);
        if (list == null) {
            list = [];
        }

        _appendEntry(list, typeCode.toNumber(), timestamp.toNumber());
        return true;
    }

    function _appendEntry(list, typeCode, ts) {
        var entry = {
            "t" => typeCode,
            "ts" => ts
        };

        var updatedList = _insertEntryByTimestamp(list, entry, ts);
        Application.Storage.setValue(STORAGE_KEY, updatedList);
        _memList = updatedList;
        _memReady = true;
        _updateRecentCachesAfterAppend(entry);
    }

    function _insertEntryByTimestamp(list, entry, ts) {
        var out = [];
        var inserted = false;
        var arr = list as Array;
        var n = arr.size();
        var i;

        var lastTs = null;
        var lastIndex = -1;
        if (n > 0) {
            var j = n - 1;
            while (j >= 0) {
                var candidateTs = _safeEntryTimestamp(arr[j]);
                if (candidateTs != null) {
                    lastTs = candidateTs;
                    lastIndex = j;
                    break;
                }
                j -= 1;
            }
        }
        if (n == 0 || lastTs == null || (lastIndex == n - 1 && ts >= lastTs)) {
            arr.add(entry);
            return arr;
        }

        for (i = 0; i < n; i += 1) {
            var existing = arr[i];
            var existingTs = _safeEntryTimestamp(existing);
            if (!inserted && existingTs != null && ts < existingTs) {
                out.add(entry);
                inserted = true;
            }
            out.add(existing);
        }

        if (!inserted) {
            out.add(entry);
        }

        return out;
    }

    function _toNumberOrNull(value) {
        if (value == null || !(value has :toNumber)) {
            return null;
        }

        return value.toNumber();
    }

    function _safeEntryTimestamp(entry) {
        if (entry == null || !(entry instanceof Dictionary)) {
            return null;
        }

        var d = entry as Dictionary;
        var raw = d["ts"];
        if (raw == null) {
            raw = d[:ts];
        }

        var ts = _toNumberOrNull(raw);
        if (ts == null || ts <= 0) {
            return null;
        }

        return ts;
    }

    function _safeEntryTypeCode(entry) {
        if (entry == null || !(entry instanceof Dictionary)) {
            return null;
        }

        var d = entry as Dictionary;
        var v = d["t"];
        if (v == null) {
            v = d[:t];
        }

        var n = _toNumberOrNull(v);
        if (n == 1 || n == 2 || n == 3 || n == 4) {
            return n;
        }

        return null;
    }

    function _isValidEntryForRecent(entry) {
        return _safeEntryTimestamp(entry) != null && _safeEntryTypeCode(entry) != null;
    }

    function _entryMatchesRecentMode(entry, mode) {
        var t = _safeEntryTypeCode(entry);
        if (t == null) {
            return false;
        }

        if (mode == 1) {
            return t == 1 || t == 2 || t == 3;
        }

        if (mode == 2) {
            return t == 4;
        }

        return true;
    }

    function _recentEntries(list, mode, maxCount) {
        var recent = [];
        if (list == null || !(list instanceof Array)) {
            return recent;
        }

        var arr = list as Array;
        var i = arr.size() - 1;
        while (i >= 0 && recent.size() < maxCount) {
            var entry = arr[i];
            if (_isValidEntryForRecent(entry) && _entryMatchesRecentMode(entry, mode)) {
                recent.add({
                    "t" => _safeEntryTypeCode(entry),
                    "ts" => _safeEntryTimestamp(entry)
                });
            }
            i -= 1;
        }

        var ordered = [];
        for (i = recent.size() - 1; i >= 0; i -= 1) {
            ordered.add(recent[i]);
        }

        return ordered;
    }

    function _setRecentCache(key, entries) {
        try {
            Application.Storage.setValue(key, entries);
        } catch (ex) {
        }
    }

    function _storeRecentCaches(list) {
        _setRecentCache(GLANCE_RECENT_KEY, _recentEntries(list, 0, 2));
        _setRecentCache(RECENT_FEEDINGS_KEY, _recentEntries(list, 1, 3));
        _setRecentCache(RECENT_DIAPERS_KEY, _recentEntries(list, 2, 3));
        _setRecentCache(RECENT_CACHE_VERSION_KEY, RECENT_CACHE_VERSION);
    }

    function _ensureRecentCaches(list) {
        var version = Application.Storage.getValue(RECENT_CACHE_VERSION_KEY);
        var recent = Application.Storage.getValue(GLANCE_RECENT_KEY);
        var feedings = Application.Storage.getValue(RECENT_FEEDINGS_KEY);
        var diapers = Application.Storage.getValue(RECENT_DIAPERS_KEY);
        if (version != RECENT_CACHE_VERSION ||
            recent == null || !(recent instanceof Array) ||
            feedings == null || !(feedings instanceof Array) ||
            diapers == null || !(diapers instanceof Array)) {
            _storeRecentCaches(list);
        }
    }

    function _loadRecentCache(key) {
        var version = Application.Storage.getValue(RECENT_CACHE_VERSION_KEY);
        if (version != RECENT_CACHE_VERSION) {
            _backfillRecentCachesFromHistory();
        }

        var recent = Application.Storage.getValue(key);
        if (recent != null && recent instanceof Array) {
            return recent;
        }

        _backfillRecentCachesFromHistory();
        recent = Application.Storage.getValue(key);
        if (recent != null && recent instanceof Array) {
            return recent;
        }

        return [];
    }

    function _backfillRecentCachesFromHistory() {
        var list = Application.Storage.getValue(STORAGE_KEY);
        if (list == null || !(list instanceof Array)) {
            _storeRecentCaches([]);
            return;
        }

        if ((list as Array).size() == 0) {
            _storeRecentCaches([]);
            return;
        }

        _storeRecentCaches(list);
    }

    function _isValidTypeCode(typeCode) {
        if (typeCode == null) {
            return false;
        }

        var n = typeCode.toNumber();
        return n == 1 || n == 2 || n == 3 || n == 4;
    }

    function _isValidTimestamp(timestamp) {
        if (timestamp == null) {
            return false;
        }

        var ts = timestamp.toNumber();
        return ts > 0 && ts <= Time.now().value();
    }

    function undoLast() {
        var list = load(true);
        if (list == null || list.size() == 0) {
            return false;
        }

        var newList = list.slice(0, list.size() - 1);
        Application.Storage.setValue(STORAGE_KEY, newList);
        _memList = newList;
        _memReady = true;
        _storeRecentCaches(newList);
        return true;
    }

    // screen 1: remove newest t in {1,2,3}. screen 2: remove newest t==4. screen 3: no-op.
    function undoLastForScreen(screen) {
        var list = load(true);
        if (list == null || list.size() == 0) {
            return false;
        }

        if (screen == 3) {
            return false;
        }

        var listArr = list as Array;
        var listSz = listArr.size();
        var i;
        for (i = listSz - 1; i >= 0; i -= 1) {
            var t = _safeEntryTypeCode(listArr[i]);
            if (t == null) {
                continue;
            }

            var match = false;
            if (screen == 1) {
                match = (t == 1 || t == 2 || t == 3);
            } else if (screen == 2) {
                match = (t == 4);
            }

            if (match) {
                var newList = [];
                var k;
                for (k = 0; k < listSz; k += 1) {
                    if (k != i) {
                        newList.add(listArr[k]);
                    }
                }
                Application.Storage.setValue(STORAGE_KEY, newList);
                _memList = newList;
                _memReady = true;
                _storeRecentCaches(newList);
                return true;
            }
        }

        return false;
    }

    function clearAll() {
        Application.Storage.setValue(STORAGE_KEY, []);
        _memList = [];
        _memReady = true;
        _storeRecentCaches([]);
    }
}

import Toybox.Application;
import Toybox.Lang;
import Toybox.Time;

// Persistent, append-only feeding entry store backed by Application Storage.
// Intended to be storage-safe even across builds: store only primitives and arrays/dictionaries.
// entry["t"] is numeric: 1=Left, 2=Right, 3=Bottle, 4=Diaper.
class FeedingStore {

    var STORAGE_KEY = "feedings_v1";
    var GLANCE_RECENT_KEY = "glance_recent_v1";

    function load() {
        var list = Application.Storage.getValue(STORAGE_KEY);

        if (list == null) {
            _storeGlanceRecent([]);
            return [];
        }

        _ensureGlanceRecent(list);
        return list;
    }

    function append(typeCode) {
        appendAt(typeCode, Time.now().value());
    }

    function appendAt(typeCode, timestamp) {
        if (!_isValidTypeCode(typeCode) || !_isValidTimestamp(timestamp)) {
            return false;
        }

        var list = load();
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
        _storeGlanceRecent(updatedList);
    }

    function _insertEntryByTimestamp(list, entry, ts) {
        var out = [];
        var inserted = false;
        var arr = list as Array;
        var n = arr.size();
        var i;

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

    function _entryTimestamp(entry) {
        if (entry == null) {
            return null;
        }

        var d = entry as Dictionary;
        var raw = d["ts"];
        if (raw == null) {
            raw = d[:ts];
        }
        if (raw == null) {
            return null;
        }

        return raw.toNumber();
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

    function _isValidEntryForGlance(entry) {
        return _safeEntryTimestamp(entry) != null && _safeEntryTypeCode(entry) != null;
    }

    function _glanceScanLimit() {
        return 20;
    }

    function _recentEntriesForGlance(list) {
        var recent = [];
        if (list == null || !(list instanceof Array)) {
            return recent;
        }

        var arr = list as Array;
        var i = arr.size() - 1;
        var scanned = 0;
        while (i >= 0 && scanned < _glanceScanLimit() && recent.size() < 2) {
            var entry = arr[i];
            if (_isValidEntryForGlance(entry)) {
                recent.add({
                    "t" => _safeEntryTypeCode(entry),
                    "ts" => _safeEntryTimestamp(entry)
                });
            }
            scanned += 1;
            i -= 1;
        }

        if (recent.size() == 2) {
            return [recent[1], recent[0]];
        }

        return recent;
    }

    function _storeGlanceRecent(list) {
        try {
            Application.Storage.setValue(GLANCE_RECENT_KEY, _recentEntriesForGlance(list));
        } catch (ex) {
        }
    }

    function _ensureGlanceRecent(list) {
        var recent = Application.Storage.getValue(GLANCE_RECENT_KEY);
        if (recent == null || !(recent instanceof Array)) {
            _storeGlanceRecent(list);
        }
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
        var list = load();
        if (list == null || list.size() == 0) {
            return false;
        }

        var newList = list.slice(0, list.size() - 1);
        Application.Storage.setValue(STORAGE_KEY, newList);
        _storeGlanceRecent(newList);
        return true;
    }

    function _entryTypeCode(entry) {
        if (entry == null) {
            return null;
        }

        var d = entry as Dictionary;
        var v = d["t"];
        if (v == null) {
            v = d[:t];
        }
        if (v == null) {
            return null;
        }

        return v.toNumber();
    }

    // screen 1: remove newest t in {1,2,3}. screen 2: remove newest t==4. screen 3: no-op.
    function undoLastForScreen(screen) {
        var list = load();
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
                _storeGlanceRecent(newList);
                return true;
            }
        }

        return false;
    }

    function clearAll() {
        Application.Storage.setValue(STORAGE_KEY, []);
        _storeGlanceRecent([]);
    }
}

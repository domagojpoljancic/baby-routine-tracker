import Toybox.Application;
import Toybox.Time;

// Persistent, append-only feeding entry store backed by Application Storage.
// Intended to be storage-safe even across builds: store only primitives and arrays/dictionaries.
// entry["t"] is numeric: 1=Left, 2=Right, 3=Bottle.
class FeedingStore {

    var STORAGE_KEY = "feedings_v1";

    function load() {
        var list = Application.Storage.getValue(STORAGE_KEY);

        if (list == null) {
            return [];
        }

        return list;
    }

    function append(typeCode) {
        var list = load();
        if (list == null) {
            list = [];
        }

        var ts = Time.now().value(); // Unix timestamp (UTC seconds since epoch).

        var entry = {
            "t" => typeCode,
            "ts" => ts
        };

        list.add(entry);

        Application.Storage.setValue(STORAGE_KEY, list);
    }

    function clearAll() {
        Application.Storage.setValue(STORAGE_KEY, []);
    }
}

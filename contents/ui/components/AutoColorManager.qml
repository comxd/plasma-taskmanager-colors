/*
    SPDX-FileCopyrightText: 2026 ComExpertise
    SPDX-License-Identifier: GPL-2.0-or-later

    Auto color extraction from application icons.
    Self-contained pipeline: queues apps, extracts dominant color
    via its own Kirigami.ImageColors instance, caches results.
*/

import QtQuick
import org.kde.kirigami as Kirigami
import org.kde.plasma.plasmoid
import "../utils/colorUtils.js" as ColorUtils

Item {
    id: autoColorManager

    visible: false
    width: 0; height: 0

    // Required input
    property bool autoEnabled: false

    // Output properties
    property var autoColorCache: ({})
    property bool queueBusy: _queue.length > 0 || _currentJob !== ""

    // Emitted when a new auto color is resolved (individual, not connected to applyDebounce)
    signal autoColorResolved(string appId, string hex)
    // Emitted when the extraction queue is fully drained — triggers single applyColors cycle
    signal queueDrained()

    // Internal state
    property var _queue: []
    property var _parsedCache: ({})
    property var _sessionExtracted: ({})
    property string _currentJob: ""
    property int _jobSeq: 0           // monotonic counter, incremented on each new extraction job
    property int _pendingJobSeq: 0   // _jobSeq of the source that was committed to ImageColors

    // ── Public API ──

    function updateTaskList(tasks, colorMap) {
        if (!autoEnabled) return;

        let skipList = [];
        try {
            skipList = JSON.parse(plasmoid.configuration.autoColorSkippedApps);
            if (!Array.isArray(skipList)) skipList = [];
        } catch (e) {
            skipList = [];
        }

        // Build unique app set from tasks
        let seen = {};
        let uniqueApps = [];
        for (let i = 0; i < tasks.length; i++) {
            let task = tasks[i];
            let appId = task.appId;
            if (!appId || seen[appId]) continue;
            seen[appId] = true;
            // iconName is var (QIcon object from model.decoration) — preserve type, do not coerce to string
            uniqueApps.push({appId: appId, iconName: task.iconName});
        }

        let newQueue = [];
        let needsPersist = false;

        for (let i = 0; i < uniqueApps.length; i++) {
            let app = uniqueApps[i];
            let appId = app.appId;

            // Skip if manual color/nyan exists or app is in skip list
            if (colorMap[appId] !== undefined) continue;
            if (skipList.indexOf(appId) >= 0) continue;

            if (_parsedCache[appId]) {
                if (!_sessionExtracted[appId]) {
                    // Enqueue for re-validation (icon may have changed)
                    newQueue.push({appId: appId, iconName: app.iconName});
                }

                // Direct mutation OK — _parsedCache is internal, no bindings depend on lastSeen changes.
                // Only update lastSeen if more than 1 hour old to avoid unnecessary persistTimer restarts.
                let now = Date.now();
                if (!_parsedCache[appId].lastSeen || (now - _parsedCache[appId].lastSeen) > 3600000) {
                    _parsedCache[appId].lastSeen = now;
                    needsPersist = true;
                }
            } else {
                // New app — enqueue for extraction
                newQueue.push({appId: appId, iconName: app.iconName});
            }
        }

        // Persist lastSeen updates so active apps don't age out of the 30-day cleanup
        if (needsPersist) persistTimer.restart();

        // Enqueue new items (avoid duplicates with existing queue)
        let queuedIds = {};
        for (let i = 0; i < _queue.length; i++) {
            queuedIds[_queue[i].appId] = true;
        }
        for (let i = 0; i < newQueue.length; i++) {
            if (!queuedIds[newQueue[i].appId]) {
                _queue = _queue.concat([newQueue[i]]);
            }
        }

        // Single-pass output rebuild from _parsedCache (D4)
        _rebuildOutput(colorMap, skipList);

        if (_queue.length > 0 && _currentJob === "") {
            drainTimer.start();
        }
    }

    function triggerFullRefresh() {
        _sessionExtracted = ({});
        // Queue will be rebuilt on next updateTaskList() call
    }

    // ── Internal logic ──

    function _drainNext() {
        // B2: guard against concurrent extractions
        if (_currentJob !== "") return;

        if (_queue.length === 0) {
            drainTimer.stop();
            queueDrained();
            return;
        }

        if (!autoEnabled) {
            _queue = [];
            drainTimer.stop();
            queueDrained();
            return;
        }

        // Pop first item
        let item = _queue[0];
        _queue = _queue.slice(1);

        // Skip if already extracted this session and color unchanged
        if (_sessionExtracted[item.appId] && _parsedCache[item.appId]) {
            // Already done — continue to next or signal drained
            if (_queue.length > 0) drainTimer.restart();
            else queueDrained();
            return;
        }

        _jobSeq++;
        _currentJob = item.appId;
        extractTimeout.restart();

        // Force ImageColors source change to ensure onPaletteChanged fires
        // iconName is var (QIcon object) — passed directly to ImageColors source
        autoImageColors.source = "";
        let mySeq = _jobSeq;
        Qt.callLater(function() {
            // If another job started between now and the deferred call, abort
            if (autoColorManager._jobSeq !== mySeq) return;
            autoColorManager._pendingJobSeq = mySeq;
            autoImageColors.source = item.iconName;
        });
    }

    function _cleanupOldEntries() {
        let now = Date.now();
        let maxAge = 30 * 24 * 3600 * 1000; // 30 days
        let changed = false;

        for (let appId in _parsedCache) {
            if (now - _parsedCache[appId].lastSeen > maxAge) {
                delete _parsedCache[appId];
                changed = true;
            }
        }

        if (changed) {
            plasmoid.configuration.autoColorCache = JSON.stringify(_parsedCache);
        }
    }

    function _rebuildOutput(colorMap, skipList) {
        let output = {};
        for (let appId in _parsedCache) {
            if (_parsedCache[appId].color) {
                if (colorMap[appId] === undefined) {
                    if (skipList.indexOf(appId) < 0) {
                        output[appId] = _parsedCache[appId].color;
                    }
                }
            }
        }
        autoColorCache = output;
    }

    function _currentColorMap() {
        try { return JSON.parse(plasmoid.configuration.appColorMap); } catch(e) { return {}; }
    }

    function _currentSkipList() {
        try {
            let list = JSON.parse(plasmoid.configuration.autoColorSkippedApps);
            return Array.isArray(list) ? list : [];
        } catch(e) { return []; }
    }

    // ── Internal components ──

    Timer {
        id: drainTimer
        interval: 150
        repeat: false
        onTriggered: autoColorManager._drainNext()
    }

    Timer {
        id: persistTimer
        interval: 5000
        repeat: false
        onTriggered: {
            plasmoid.configuration.autoColorCache = JSON.stringify(autoColorManager._parsedCache);
        }
    }

    // Safety timeout — reset if paletteChanged never fires
    Timer {
        id: extractTimeout
        interval: 3000
        repeat: false
        onTriggered: {
            autoColorManager._currentJob = "";
            if (autoColorManager._queue.length > 0) {
                drainTimer.restart();
            } else {
                autoColorManager.queueDrained();
            }
        }
    }

    Kirigami.ImageColors {
        id: autoImageColors

        onPaletteChanged: {
            if (autoColorManager._currentJob === "") return;

            // Verify this result is for the current job (not a stale timed-out job)
            // _pendingJobSeq is set when the source is committed, _jobSeq increments on each new job
            // Race: A times out → B starts (_jobSeq++) → late A paletteChanged → _pendingJobSeq (A's) != _jobSeq (B's) → discard
            if (autoColorManager._pendingJobSeq !== autoColorManager._jobSeq) return;

            extractTimeout.stop();

            let c = autoImageColors.dominant;
            if (!c) {
                autoColorManager._currentJob = "";
                if (autoColorManager._queue.length > 0) {
                    drainTimer.restart();
                } else {
                    autoColorManager.queueDrained();
                }
                return;
            }

            let hex = ColorUtils.colorToHex(c);
            let appId = autoColorManager._currentJob;
            let existing = autoColorManager._parsedCache[appId];

            if (existing && existing.color === hex) {
                // Same color — just mark as extracted
                let se = Object.assign({}, autoColorManager._sessionExtracted);
                se[appId] = true;
                autoColorManager._sessionExtracted = se;
            } else {
                // New or changed color
                let cache = Object.assign({}, autoColorManager._parsedCache);
                cache[appId] = {color: hex, lastSeen: Date.now()};
                autoColorManager._parsedCache = cache;

                let se = Object.assign({}, autoColorManager._sessionExtracted);
                se[appId] = true;
                autoColorManager._sessionExtracted = se;

                persistTimer.restart();
                autoColorManager.autoColorResolved(appId, hex);
            }

            // B4: rebuild output with current colorMap/skipList to filter properly
            autoColorManager._rebuildOutput(autoColorManager._currentColorMap(), autoColorManager._currentSkipList());

            autoColorManager._currentJob = "";
            if (autoColorManager._queue.length > 0) {
                drainTimer.restart();
            } else {
                autoColorManager.queueDrained();
            }
        }
    }

    Component.onCompleted: {
        try {
            _parsedCache = JSON.parse(plasmoid.configuration.autoColorCache);
        } catch (e) {
            _parsedCache = {};
        }
        _cleanupOldEntries();
        // B3: parse config at startup instead of passing null
        _rebuildOutput(_currentColorMap(), _currentSkipList());
    }
}

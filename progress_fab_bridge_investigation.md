# Investigation: progress_fab_bridge.js – APEX 26.1 "Invalid model data" Error

## Error

```
Invalid model data. Proceeding with no data.
e.error                @  desktop_all.min.js?v=26.1.0:7
e.initialModelData     @  modelViewBase.min.js?v=26.1.0:4
i.templateReportRegionInit  @  widget.templateReport.min.js?v=26.1.0:4
(anonymous)            @  home?debug=NO&session=...:320
e.init                 @  desktop_all.min.js?v=26.1.0:22
...jQuery ready (setTimeout)...
```

## Root Cause

**`progress_fab_bridge.js` is not directly in the error stack.** The error originates inside APEX 26.1's own `widget.templateReport.min.js` → `modelViewBase.min.js`. However, the bridge is the **indirect trigger** via a timing bug.

### Timing sequence (before the fix)

| Step | What happens |
|------|-------------|
| 1 | `DOMContentLoaded` fires |
| 2 | Bridge `run()` executes immediately (registered at DOMContentLoaded) |
| 3 | Bridge moves `.progress-items`, badge, templates **out of** `.progress-container` |
| 4 | Bridge stamps `.is-merged` on `.progress-container` |
| 5 | jQuery-ready queue fires (via `setTimeout`) |
| 6 | APEX calls `templateReportRegionInit` on the region |
| 7 | APEX reads the `.progress-container` DOM to build model data |
| 8 | Container is now gutted/modified → APEX generates null/invalid model data |
| 9 | `initialModelData` logs **"Invalid model data. Proceeding with no data."** |

In APEX 26.1, `templateReportRegionInit` / `modelViewBase.initialModelData` appears to
read the live region DOM to construct its initial model configuration. Finding the
container already modified (children moved, `is-merged` class set) causes it to produce
invalid model data.

The error is **non-fatal** — APEX logs it and continues with no initial server-rendered
rows. The WebSocket connection in `progress_tracker.js` still works and pushes updates
normally.

## Fix Applied

**File:** `static-files/progress_fab_bridge.js`

### Before

```javascript
if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', run);
} else {
    run();
}

if (window.apex && window.apex.jQuery) {
    window.apex.jQuery(document).on('apexafterrefresh apexreadyend', run);
}
```

### After

```javascript
// On APEX pages: wait for apexreadyend (after templateReportRegionInit).
// On non-APEX pages: fall back to DOMContentLoaded.
if (window.apex && window.apex.jQuery) {
    window.apex.jQuery(document).on('apexreadyend apexafterrefresh', run);
} else if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', run);
} else {
    run();
}
```

**Effect:** The bridge's first `run()` now fires at `apexreadyend`, which is after APEX
has finished initializing all regions (including `templateReportRegionInit`). The
`.progress-container` DOM is intact when APEX reads it, so model data is generated
correctly. Subsequent refreshes are handled by `apexafterrefresh` as before.

The CSS rule `.progress-container:not(.is-merged):not(.is-ready) { visibility: hidden }`
prevents a flash of the standalone container during the brief gap before `apexreadyend`.

## Debug Tracing Added

A `dbg()` helper and `apex.debug.info` calls were added throughout `run()` to trace
every decision branch and DOM operation. Enable APEX debug mode (`?debug=YES`) to see
the full bridge execution log in the browser console, prefixed with `progress-fab-bridge:`.

Key log messages:
- `run() called, readyState=...` — entry point, shows when bridge fired
- `run() no .fab-container found` — standalone path taken
- `run() no un-merged .progress-container found` — nothing to bridge
- `run() FAB inner pieces not ready` — deferred; retry on next APEX event
- `run() step 1..9` — each DOM surgery step
- `run() bridge complete` — successful merge

## Secondary Issue (not causing the error)

In `plugin.apx`, `progress_fab_bridge.js` is listed **without `#MIN#`**:

```
#PLUGIN_FILES#progress_fab_bridge.js      -- always loads unminified
#PLUGIN_FILES#progress_tracker#MIN#.js    -- correctly uses minified in prod
```

Should be `#PLUGIN_FILES#progress_fab_bridge#MIN#.js` to load the minified version in
production. This does not cause the "Invalid model data" error but is an inconsistency.

## Files Changed

| File | Change |
|------|--------|
| `static-files/progress_fab_bridge.js` | Fixed bootstrap timing; added `apex.debug.info` tracing |
| `progress_fab_bridge_investigation.md` | This file |

## Next Steps

1. Rebuild / minify `progress_fab_bridge.min.js` from the updated source.
2. Optionally fix `plugin.apx` to reference `progress_fab_bridge#MIN#.js`.
3. Test in APEX 26.1 with `?debug=YES` and confirm:
   - No "Invalid model data" error in console
   - `progress-fab-bridge: run() called` appears in log **after** `templateReportRegionInit`
   - Bridge completes (`progress-fab-bridge: run() bridge complete`)

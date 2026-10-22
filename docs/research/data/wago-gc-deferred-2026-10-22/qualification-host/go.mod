module dewdrop.tools/wago-transform-host

go 1.22

require (
	github.com/jtenner/wago-facet v0.1.0
	github.com/wago-org/wago v0.1.0-beta.13.0.20261020170030-7997c86c36e0
)

require golang.org/x/sys v0.30.0 // indirect

replace github.com/wago-org/wago => "/tmp/wago-gc-deferred-evidence/control-source"
replace github.com/jtenner/wago-facet => "/home/dev/Projects/dewdrop/.tmp/wago-origin-main-2026-10-20/facet"

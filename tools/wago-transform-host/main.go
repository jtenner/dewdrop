package main

import (
	"encoding/json"
	"fmt"
	facet "github.com/jtenner/wago-facet/register"
	wago "github.com/wago-org/wago"
	"github.com/wago-org/wago/cli/runtime"
	"os"
)

// Set by build-wago-transform-host.py. A plain Go build stays visibly unpatched.
var runtimePatchIdentity = "unpatched"

var workerPluginIdentity = "unverified"

func main() {
	data, err := os.ReadFile("wago-lock.json")
	if err != nil {
		panic(err)
	}
	var lock struct {
		Plugins map[string]json.RawMessage `json:"plugins"`
	}
	if err := json.Unmarshal(data, &lock); err != nil {
		panic(err)
	}
	var selections []wago.PluginSelection
	for id, raw := range lock.Plugins {
		var fields map[string]json.RawMessage
		if err := json.Unmarshal(raw, &fields); err != nil {
			panic(err)
		}
		delete(fields, "contracts")
		fields["contracts"] = fields["bindings"]
		raw, err := json.Marshal(fields)
		if err != nil {
			panic(err)
		}
		var s wago.PluginSelection
		if err := json.Unmarshal(raw, &s); err != nil {
			panic(err)
		}
		s.ID = id
		selections = append(selections, s)
	}
	workerSetting := os.Getenv("DEW_TRANSFORM_WORKERS")
	if workerSetting != "" && workerSetting != "0" && workerSetting != "2" {
		panic("DEW_TRANSFORM_WORKERS must be 0 or 2")
	}
	provider, selection, err := workerProvider(workerSetting == "2")
	if err != nil {
		panic(err)
	}
	providers := append(facet.Providers(), provider)
	selections = append(selections, selection)
	fmt.Fprintln(os.Stderr, "Wago 2dd978ccda6f; patch "+runtimePatchIdentity+"; workers "+workerPluginIdentity+"; Facet v0.1.0; locked project bindings")
	runtime.MainWithPluginSet("dewdrop-transform-check", "dewdrop-2dd978ccda6f-facet-v0.1.0-"+runtimePatchIdentity+"-"+workerPluginIdentity, wago.PluginSet{Providers: providers, Selections: selections})
}

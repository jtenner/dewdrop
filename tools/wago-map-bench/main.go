package main

import (
	"flag"
	"fmt"
	"os"
	"runtime"
	"sort"
	"time"

	wago "github.com/wago-org/wago/src/wago"
)

func config() *wago.RuntimeConfig {
	return wago.NewRuntimeConfig().
		WithCoreFeatures(wago.CoreFeaturesV3).
		WithBoundsChecks(wago.BoundsChecksExplicit)
}

func totalAllocated() uint64 {
	var stats runtime.MemStats
	runtime.ReadMemStats(&stats)
	return stats.TotalAlloc
}

func main() {
	calls := flag.Int("calls", 20, "main calls per measured round")
	rounds := flag.Int("rounds", 7, "measured rounds")
	heapMiB := flag.Int("heap-mib", 512, "bounded Wago throughput heap")
	flag.Parse()
	if flag.NArg() != 1 || *calls < 1 || *rounds < 1 {
		fmt.Fprintln(os.Stderr, "usage: wago-map-bench [flags] MODULE.wasm")
		os.Exit(2)
	}
	data, err := os.ReadFile(flag.Arg(0))
	if err != nil {
		panic(err)
	}
	compiled, err := wago.Compile(config(), data)
	if err != nil {
		panic(err)
	}
	defer compiled.Close()
	instance, err := wago.Instantiate(compiled, wago.InstantiateOptions{
		GC: wago.GCConfig{ThroughputHeapBytes: uint32(*heapMiB) << 20},
	})
	if err != nil {
		panic(err)
	}
	defer instance.Close()
	for index := 0; index < 3; index++ {
		if _, invokeErr := instance.Invoke("main"); invokeErr != nil {
			panic(invokeErr)
		}
	}
	samples := make([]float64, *rounds)
	var allocated uint64
	for round := 0; round < *rounds; round++ {
		runtime.GC()
		before := totalAllocated()
		start := time.Now()
		for index := 0; index < *calls; index++ {
			if _, invokeErr := instance.Invoke("main"); invokeErr != nil {
				panic(invokeErr)
			}
		}
		samples[round] = float64(time.Since(start).Nanoseconds()) / float64(*calls)
		allocated += totalAllocated() - before
	}
	sort.Float64s(samples)
	fmt.Printf(
		"engine=wago bytes=%d median_ns=%.1f alloc_B=%.1f samples_ns=%v\n",
		len(data),
		samples[len(samples)/2],
		float64(allocated)/float64((*calls)*(*rounds)),
		samples,
	)
}

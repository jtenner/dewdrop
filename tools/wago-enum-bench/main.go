package main

import (
	"flag"
	"fmt"
	"os"
	"runtime"
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
	compileIterations := flag.Int("compile", 300, "cold compile iterations")
	instantiateIterations := flag.Int("instantiate", 2000, "instance setup iterations")
	warmupIterations := flag.Int("warmup", 100000, "warm execution calls")
	execIterations := flag.Int("exec", 1000000, "measured execution calls")
	heapMiB := flag.Int("heap-mib", 512, "bounded Wago throughput heap per execution instance")
	export := flag.String("export", "run", "i32 -> i32 export")
	flag.Parse()
	if flag.NArg() == 0 {
		fmt.Fprintln(os.Stderr, "pass one or more Wasm files")
		os.Exit(2)
	}
	for _, path := range flag.Args() {
		data, err := os.ReadFile(path)
		if err != nil {
			panic(err)
		}
		runtime.GC()
		beforeAlloc := totalAllocated()
		start := time.Now()
		for index := 0; index < *compileIterations; index++ {
			compiled, compileErr := wago.Compile(config(), data)
			if compileErr != nil {
				panic(fmt.Sprintf("%s compile: %v", path, compileErr))
			}
			if closeErr := compiled.Close(); closeErr != nil {
				panic(closeErr)
			}
		}
		compileElapsed := time.Since(start)
		compileAlloc := totalAllocated() - beforeAlloc

		compiled, err := wago.Compile(config(), data)
		if err != nil {
			panic(err)
		}
		instanceOptions := wago.InstantiateOptions{
			GC: wago.GCConfig{ThroughputHeapBytes: uint32(*heapMiB) << 20},
		}
		runtime.GC()
		beforeAlloc = totalAllocated()
		start = time.Now()
		for index := 0; index < *instantiateIterations; index++ {
			instance, instantiateErr := wago.Instantiate(compiled, instanceOptions)
			if instantiateErr != nil {
				panic(fmt.Sprintf("%s instantiate: %v", path, instantiateErr))
			}
			if closeErr := instance.Close(); closeErr != nil {
				panic(closeErr)
			}
		}
		instantiateElapsed := time.Since(start)
		instantiateAlloc := totalAllocated() - beforeAlloc

		instance, err := wago.Instantiate(compiled, instanceOptions)
		if err != nil {
			panic(err)
		}
		for index := 0; index < *warmupIterations; index++ {
			results, invokeErr := instance.Invoke(
				*export,
				wago.I32(int32(index&1023)),
			)
			if invokeErr != nil || len(results) != 1 {
				panic(fmt.Sprintf("%s warmup: %v", path, invokeErr))
			}
		}
		runtime.GC()
		beforeAlloc = totalAllocated()
		checksum := int32(0)
		start = time.Now()
		for index := 0; index < *execIterations; index++ {
			results, invokeErr := instance.Invoke(
				*export,
				wago.I32(int32(index&1023)),
			)
			if invokeErr != nil {
				panic(fmt.Sprintf("%s invoke: %v", path, invokeErr))
			}
			checksum += wago.AsI32(results[0])
		}
		execElapsed := time.Since(start)
		execAlloc := totalAllocated() - beforeAlloc
		if closeErr := instance.Close(); closeErr != nil {
			panic(closeErr)
		}
		if closeErr := compiled.Close(); closeErr != nil {
			panic(closeErr)
		}

		fmt.Printf(
			"%s bytes=%d compile_ns=%.2f compile_B=%.2f instantiate_ns=%.2f instantiate_B=%.2f exec_ns=%.2f exec_B=%.4f checksum=%d\n",
			path,
			len(data),
			float64(compileElapsed.Nanoseconds())/float64(*compileIterations),
			float64(compileAlloc)/float64(*compileIterations),
			float64(instantiateElapsed.Nanoseconds())/float64(*instantiateIterations),
			float64(instantiateAlloc)/float64(*instantiateIterations),
			float64(execElapsed.Nanoseconds())/float64(*execIterations),
			float64(execAlloc)/float64(*execIterations),
			checksum,
		)
	}
}

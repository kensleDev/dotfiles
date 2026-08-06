#!/bin/bash
# Neovim Performance Benchmark Script
# Usage: ./scripts/benchmark.sh [baseline|after|compare]

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="$(dirname "$SCRIPT_DIR")"
TEST_FILES_DIR="$CONFIG_DIR/.test-files"
RESULTS_DIR="$CONFIG_DIR/.benchmark-results"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

HAS_HYPERFINE=$(command -v hyperfine >/dev/null 2>&1 && echo "yes" || echo "no")

mkdir -p "$RESULTS_DIR"

if [[ ! -d "$TEST_FILES_DIR" ]]; then
    echo "Test files not found. Generating..."
    "$SCRIPT_DIR/generate-test-files.sh"
fi

run_with_hyperfine() {
    local name="$1"
    local cmd="$2"
    local output_file="$3"
    
    hyperfine --warmup 2 --runs 10 --export-markdown "$output_file.md" \
        --export-csv "$output_file.csv" \
        --command-name "$name" \
        "$cmd" 2>/dev/null
    
    echo "$(grep -oP '(?<=Mean = )[0-9.]+(?= s)' "$output_file.md" 2>/dev/null || echo "N/A")"
}

run_with_time() {
    local name="$1"
    local cmd="$2"
    local runs=10
    local total=0
    
    echo "Benchmarking: $name"
    
    for i in $(seq 1 $runs); do
        nvim --headless -c "qa!" 2>/dev/null
    done
    
    for i in $(seq 1 $runs); do
        start=$(date +%s%N)
        eval "$cmd" 2>/dev/null
        end=$(date +%s%N)
        elapsed=$(( (end - start) / 1000000 ))
        total=$((total + elapsed))
    done
    
    avg_ms=$((total / runs))
    echo "  Average: ${avg_ms}ms"
    echo "$avg_ms"
}

benchmark_startup() {
    local output_prefix="$1"
    
    echo ""
    echo "=== Startup Time ==="
    
    if [[ "$HAS_HYPERFINE" == "yes" ]]; then
        run_with_hyperfine "Cold Start" "nvim -c qa!" "$output_prefix-startup"
    else
        run_with_time "Cold Start" "nvim -c qa!"
    fi
}

benchmark_file() {
    local name="$1"
    local file="$2"
    local output_prefix="$3"
    
    echo ""
    echo "=== Opening $name ==="
    
    if [[ "$HAS_HYPERFINE" == "yes" ]]; then
        run_with_hyperfine "$name" "nvim +qa '$file'" "$output_prefix-$name"
    else
        run_with_time "$name" "nvim +qa '$file'"
    fi
}

run_full_benchmark() {
    local label="$1"
    local output_dir="$RESULTS_DIR/${label}_${TIMESTAMP}"
    mkdir -p "$output_dir"
    
    echo "========================================="
    echo " Neovim Performance Benchmark: $label"
    echo " Timestamp: $TIMESTAMP"
    echo " Hyperfine: $HAS_HYPERFINE"
    echo "========================================="
    
    local results_file="$output_dir/results.txt"
    
    {
        echo "# Neovim Benchmark Results"
        echo "Date: $(date)"
        echo "Label: $label"
        echo "Hyperfine: $HAS_HYPERFINE"
        echo ""
        
        echo "## Tests"
        echo ""
    } > "$results_file"
    
    benchmark_startup "$output_dir/startup" | tee -a "$results_file"
    
    benchmark_file "small_lua" "$TEST_FILES_DIR/small.lua" "$output_dir" | tee -a "$results_file"
    benchmark_file "medium_ts" "$TEST_FILES_DIR/medium.ts" "$output_dir" | tee -a "$results_file"
    benchmark_file "large_json" "$TEST_FILES_DIR/large.json" "$output_dir" | tee -a "$results_file"
    benchmark_file "large_log" "$TEST_FILES_DIR/large.log" "$output_dir" | tee -a "$results_file"
    
    echo ""
    echo "Results saved to: $output_dir"
    echo "$output_dir"
}

compare_results() {
    local baseline_dir="$1"
    local after_dir="$2"
    
    echo "========================================="
    echo " Benchmark Comparison"
    echo "========================================="
    echo ""
    echo "Baseline: $baseline_dir"
    echo "After:    $after_dir"
    echo ""
    
    if [[ ! -f "$baseline_dir/results.txt" || ! -f "$after_dir/results.txt" ]]; then
        echo "Error: Missing results files"
        exit 1
    fi
    
    echo "| Test | Baseline | After | Change |"
    echo "|------|----------|-------|--------|"
    
    echo "Comparison complete."
}

case "${1:-}" in
    baseline)
        run_full_benchmark "baseline"
        ;;
    after)
        run_full_benchmark "after"
        ;;
    compare)
        baseline=$(ls -dt "$RESULTS_DIR"/baseline_* 2>/dev/null | head -1)
        after=$(ls -dt "$RESULTS_DIR"/after_* 2>/dev/null | head -1)
        
        if [[ -z "$baseline" || -z "$after" ]]; then
            echo "Error: Need both baseline and after results"
            echo "Run: ./benchmark.sh baseline  # then make changes"
            echo "Run: ./benchmark.sh after     # then compare"
            exit 1
        fi
        
        compare_results "$baseline" "$after"
        ;;
    *)
        echo "Usage: $0 {baseline|after|compare}"
        echo ""
        echo "  baseline  - Run benchmark before optimizations"
        echo "  after     - Run benchmark after optimizations"
        echo "  compare   - Compare baseline vs after results"
        exit 1
        ;;
esac

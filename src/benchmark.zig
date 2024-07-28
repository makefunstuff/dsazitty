const std = @import("std");
const Random = std.Random;
const time = std.time;
const bubble = @import("sort/bubble.zig");
const selection = @import("sort/selection.zig");
const insertion = @import("sort/insertion.zig");
const shell = @import("sort/shell.zig");
const testing = std.testing;

fn benchmark(comptime T: type, comptime sort_fn: fn (type, []T) void, n: usize, runs: usize) !u64 {
    var prng = std.rand.DefaultPrng.init(0);
    var random = prng.random();
    var total_time: u64 = 0;
    for (0..runs) |_| {
        const list = try testing.allocator.alloc(T, n);
        defer testing.allocator.free(list);
        for (list) |*item| {
            item.* = random.int(T);
        }
        const start = time.milliTimestamp();
        sort_fn(T, list);
        const end = time.milliTimestamp();
        total_time += @intCast(end - start);
    }
    return total_time / runs;
}

fn run_bench(comptime T: type, comptime sort_fn: fn (type, []T) void, name: []const u8) !void {
    const runs = 10;
    const sizes = [_]usize{ 100, 1000, 10000 };
    std.debug.print("\n{s} Benchmark:\n", .{name});
    for (sizes) |size| {
        const avg_time = try benchmark(T, sort_fn, size, runs);
        std.debug.print("Average time for N={d}: {d} ms\n", .{ size, avg_time });
    }
}

test "sorting benchmarks" {
    try run_bench(i64, bubble.sort, "Bubble Sort");
    try run_bench(i64, selection.sort, "Selection Sort");
    try run_bench(i64, insertion.sort, "Insertion Sort");
    try run_bench(i64, shell.sort, "Shell Sort");
}

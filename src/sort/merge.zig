const std = @import("std");
const mem = std.mem;
const testing = std.testing;
const Allocator = std.mem.Allocator;

fn sort_helper(comptime T: type, arr: []T, aux: []T, low: usize, high: usize) void {
    if (high - low <= 1) return;
    const mid = low + (high - low) / 2;
    sort_helper(T, arr, aux, low, mid);
    sort_helper(T, arr, aux, mid, high);
    merge(T, arr, aux, low, mid, high);
}

fn merge(comptime T: type, arr: []T, aux: []T, low: usize, mid: usize, high: usize) void {
    @memcpy(aux[low..high], arr[low..high]);
    var i = low;
    var j = mid;
    var k = low;
    while (k < high) : (k += 1) {
        if (i < mid and (j == high or aux[i] <= aux[j])) {
            arr[k] = aux[i];
            i += 1;
        } else {
            arr[k] = aux[j];
            j += 1;
        }
    }
}

pub fn sort(comptime T: type, arr: []T, allocator: *Allocator) !void {
    const aux = try allocator.alloc(T, arr.len);
    defer allocator.free(aux);
    sort_helper(T, arr, aux, 0, arr.len);
}

test "optimized merge sort - basic test" {
    var arr = [_]i64{ 20, 3, 5, 1, 30, 4, 2 };
    var allocator = testing.allocator;
    try sort(i64, &arr, &allocator);
    const expected = [_]i64{ 1, 2, 3, 4, 5, 20, 30 };
    try testing.expectEqualSlices(i64, &expected, &arr);
}

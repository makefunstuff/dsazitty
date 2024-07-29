const std = @import("std");
const testing = std.testing;
const mem = std.mem;

fn partition(comptime T: type, arr: []T, low: usize, high: usize) usize {
    const pivot = arr[high];
    var i: usize = low;

    for (low..high) |j| {
        if (arr[j] <= pivot) {
            mem.swap(T, &arr[i], &arr[j]);
            i += 1;
        }
    }
    mem.swap(T, &arr[i], &arr[high]);
    return i;
}

pub fn sort(comptime T: type, arr: []T, low: usize, high: usize) void {
    if (low < high) {
        const pivot_index = partition(T, arr, low, high);

        if (pivot_index > low) {
            sort(T, arr, low, pivot_index - 1);
        }
        sort(T, arr, pivot_index + 1, high);
    }
}

test "quick sort" {
    var arr = [_]i32{ 64, 34, 25, 12, 22, 11, 90 };
    sort(i32, &arr, 0, arr.len - 1);
    const expected = [_]i32{ 11, 12, 22, 25, 34, 64, 90 };
    try testing.expectEqualSlices(i32, &expected, &arr);
}

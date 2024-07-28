const std = @import("std");
const mem = std.mem;
const testing = std.testing;

pub fn sort(comptime T: type, arr: []T) void {
    for (1..arr.len) |i| {
        var j = i;
        while (j > 0 and arr[j - 1] > arr[j]) : (j -= 1) {
            mem.swap(T, &arr[j - 1], &arr[j]);
        }
    }
}

test "insertion sort test" {
    var arr = [_]i64{ 20, 3, 5, 1, 30, 4, 2 };
    sort(i64, &arr);
    const expected = [_]i64{ 1, 2, 3, 4, 5, 20, 30 };
    try testing.expectEqualSlices(i64, &expected, &arr);
}

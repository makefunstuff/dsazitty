const std = @import("std");
const mem = std.mem;
const testing = std.testing;

pub fn sort(comptime T: type, arr: []T) void {
    for (0..arr.len - 1) |i| {
        var min = i;
        for (i + 1..arr.len) |j| {
            if (arr[min] > arr[j]) {
                min = j;
            }
        }
        mem.swap(T, &arr[i], &arr[min]);
    }
}

test "selection sort test" {
    var arr = [_]i64{ 20, 3, 5, 1, 30, 4, 2 };
    sort(i64, &arr);
    const expected = [_]i64{ 1, 2, 3, 4, 5, 20, 30 };
    try testing.expectEqual(expected, arr);
}

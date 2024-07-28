const std = @import("std");
const mem = std.mem;
const testing = std.testing;

pub fn sort(comptime T: type, arr: []T) void {
    var gap = arr.len / 2;

    while (gap > 0) : (gap /= 2) {
        var i: usize = gap;
        while (i < arr.len) : (i += 1) {
            const temp = arr[i];
            var j: usize = i;
            while (j >= gap and arr[j - gap] > temp) : (j -= gap) {
                arr[j] = arr[j - gap];
            }
            arr[j] = temp;
        }
    }
}

test "insertion sort test" {
    var arr = [_]i64{ 20, 3, 5, 1, 30, 4, 2 };
    sort(i64, &arr);
    const expected = [_]i64{ 1, 2, 3, 4, 5, 20, 30 };
    try testing.expectEqualSlices(i64, &expected, &arr);
}

const std = @import("std");
const c = @import("c.zig");

pub fn main() !void {
    const width = 800;
    const height = 600;
    c.InitWindow(width, height, "dsa viz");
    c.SetTargetFPS(60);

    const original: [6]i32 = .{ 10, 3, 4, 1, 50, 30 };
    var input_array: [6]i32 = original;
    var i: usize = 0;
    var j: usize = 0;

    while (!c.WindowShouldClose()) {
        c.ClearBackground(c.BLACK);

        c.BeginDrawing();
        var x_pos: i32 = width / 2;
        for (input_array) |e| {
            c.DrawRectangle(x_pos, height - (height / 2) - (e * 5), 20, e * 5, c.RED);
            x_pos += 30;
        }

        if (j < input_array.len - 1 - i) {
            if (input_array[j] > input_array[j + 1]) {
                const temp = input_array[j];
                input_array[j] = input_array[j + 1];
                input_array[j + 1] = temp;
            }
            j += 1;
        } else {
            i += 1;
            j = 0;

            if (i >= input_array.len - 1) {
                input_array = original;
                i = 0;
                j = 0;
            }
        }
        c.WaitTime(0.5);

        c.EndDrawing();
    }
}

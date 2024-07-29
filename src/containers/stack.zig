const std = @import("std");
const Allocator = std.mem.Allocator;
const testing = std.testing;

// Linked list based stack implementation
pub fn Node(comptime T: type) type {
    return struct {
        const Self = @This();
        next: ?*Self = null,
        value: T,

        pub fn init(allocator: *Allocator, value: T) !*Self {
            const self = try allocator.create(Self);
            self.* = .{ .value = value, .next = null };
            return self;
        }

        pub fn deinit(self: *Self, allocator: *Allocator) void {
            allocator.destroy(self);
        }
    };
}

pub fn Stack(comptime T: type) type {
    return struct {
        const Self = @This();
        const NodeT = Node(T);

        count: u64,
        head: ?*NodeT,
        allocator: *Allocator,

        pub fn init(allocator: *Allocator) Self {
            return Self{
                .count = 0,
                .head = null,
                .allocator = allocator,
            };
        }

        pub fn deinit(self: *Self) void {
            while (self.head) |node| {
                self.head = node.next;
                node.deinit(self.allocator);
            }
        }

        pub fn is_empty(self: *Self) bool {
            return self.count == 0;
        }

        pub fn size(self: *Self) u64 {
            return self.count;
        }

        pub fn push(self: *Self, value: T) !void {
            const node = try NodeT.init(self.allocator, value);
            node.next = self.head;
            self.head = node;
            self.count += 1;
        }

        pub fn pop(self: *Self) !T {
            if (self.head) |head| {
                const val = head.value;
                self.head = head.next;
                self.count -= 1;
                head.deinit(self.allocator);
                return val;
            } else {
                return error.EmptyStack;
            }
        }
    };
}

test "Stack operations" {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    var allocator = arena.allocator();

    const IntStack = Stack(i32);
    var stack = IntStack.init(&allocator);
    defer stack.deinit();

    // Test initial state
    try testing.expect(stack.is_empty());
    try testing.expectEqual(@as(u64, 0), stack.size());

    // Test push
    try stack.push(10);
    try testing.expect(!stack.is_empty());
    try testing.expectEqual(@as(u64, 1), stack.size());

    try stack.push(20);
    try testing.expectEqual(@as(u64, 2), stack.size());

    // Test pop
    const val1 = try stack.pop();
    try testing.expectEqual(@as(i32, 20), val1);
    try testing.expectEqual(@as(u64, 1), stack.size());

    const val2 = try stack.pop();
    try testing.expectEqual(@as(i32, 10), val2);
    try testing.expect(stack.is_empty());

    // Test pop on empty stack
    try testing.expectError(error.EmptyStack, stack.pop());
}

const std = @import("std");
const Allocator = std.mem.Allocator;
const testing = std.testing;

pub fn Node(comptime T: type) type {
    return struct {
        const Self = @This();
        left: ?*Self = null,
        right: ?*Self = null,
        value: T,

        pub fn init(allocator: *Allocator, value: T) !*Self {
            const self = try allocator.create(Self);
            self.* = .{ .value = value, .left = null, .right = null };
            return self;
        }

        pub fn deinit(self: *Self, allocator: *Allocator) void {
            if (self.left) |left| left.deinit(allocator);
            if (self.right) |right| right.deinit(allocator);
            allocator.destroy(self);
        }
    };
}

pub fn BST(comptime T: type) type {
    return struct {
        const Self = @This();
        const NodeT = Node(T);

        root: ?*NodeT = null,
        allocator: *Allocator,

        pub fn init(allocator: *Allocator) Self {
            return Self{ .allocator = allocator };
        }

        pub fn deinit(self: *Self) void {
            if (self.root) |root| root.deinit(self.allocator);
        }

        pub fn insert(self: *Self, value: T) !void {
            if (self.root == null) {
                self.root = try NodeT.init(self.allocator, value);
            } else {
                try self.insertRecursive(self.root.?, value);
            }
        }

        fn insertRecursive(self: *Self, node: *NodeT, value: T) !void {
            if (value < node.value) {
                if (node.left == null) {
                    node.left = try NodeT.init(self.allocator, value);
                } else {
                    try self.insertRecursive(node.left.?, value);
                }
            } else if (value > node.value) {
                if (node.right == null) {
                    node.right = try NodeT.init(self.allocator, value);
                } else {
                    try self.insertRecursive(node.right.?, value);
                }
            }
        }

        pub fn search(self: *Self, value: T) bool {
            return self.searchRecursive(self.root, value);
        }

        fn searchRecursive(self: *Self, node: ?*NodeT, value: T) bool {
            if (node) |n| {
                if (value == n.value) return true;
                if (value < n.value) return self.searchRecursive(n.left, value);
                if (value > n.value) return self.searchRecursive(n.right, value);
            }
            return false;
        }

        pub fn inorderTraversal(self: *Self, list: *std.ArrayList(T)) !void {
            try self.inorderTraversalRecursive(self.root, list);
        }

        fn inorderTraversalRecursive(self: *Self, node: ?*NodeT, list: *std.ArrayList(T)) !void {
            if (node) |n| {
                try self.inorderTraversalRecursive(n.left, list);
                try list.append(n.value);
                try self.inorderTraversalRecursive(n.right, list);
            }
        }

        pub fn min(self: *Self) ?T {
            var current = self.root;
            while (current) |n| {
                if (n.left == null) return n.value;
                current = n.left;
            }
            return null;
        }

        pub fn max(self: *Self) ?T {
            var current = self.root;
            while (current) |n| {
                if (n.right == null) return n.value;
                current = n.right;
            }
            return null;
        }
    };
}

test "BST operations" {
    var arena = std.heap.ArenaAllocator.init(std.testing.allocator);
    defer arena.deinit();
    var allocator = arena.allocator();

    var bst = BST(i32).init(&allocator);
    defer bst.deinit();

    // Test insert and search
    try bst.insert(5);
    try bst.insert(3);
    try bst.insert(7);
    try bst.insert(1);
    try bst.insert(9);

    try testing.expect(bst.search(5));
    try testing.expect(bst.search(1));
    try testing.expect(bst.search(9));
    try testing.expect(!bst.search(4));
    try testing.expect(!bst.search(10));

    // Test min and max
    try testing.expectEqual(@as(?i32, 1), bst.min());
    try testing.expectEqual(@as(?i32, 9), bst.max());

    // Test inorder traversal
    var list = std.ArrayList(i32).init(allocator);
    defer list.deinit();
    try bst.inorderTraversal(&list);

    const expected = [_]i32{ 1, 3, 5, 7, 9 };
    try testing.expectEqualSlices(i32, &expected, list.items);
}

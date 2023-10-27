const std = @import("std");

const Step = enum { rock, paper, scissors };
const Result = enum { win, draw, loss };

const EncryptError = error{StepError};

fn decryptStep(step: u8) EncryptError!Step {
    const result: EncryptError!Step = switch (step) {
        'A' => .rock,
        'B' => .paper,
        'C' => .scissors,
        'X' => .rock,
        'Y' => .paper,
        'Z' => .scissors,
        else => EncryptError.StepError,
    };

    return result;
}

fn getResult(myStep: Step, opponentStep: Step) Result {
    const result: Result = switch (myStep) {
        .rock => switch (opponentStep) {
            .rock => Result.draw,
            .paper => Result.loss,
            .scissors => Result.win,
        },
        .paper => switch (opponentStep) {
            .paper => Result.draw,
            .rock => Result.win,
            .scissors => Result.loss,
        },
        .scissors => switch (opponentStep) {
            .scissors => Result.draw,
            .rock => Result.loss,
            .paper => Result.win,
        },
    };

    return result;
}

fn getStepScore(step: Step) i8 {
    const stepScore: i8 = switch (step) {
        .rock => 1,
        .paper => 2,
        .scissors => 3,
    };
    return stepScore;
}

fn getResultScore(result: Result) i8 {
    const resultScore: i8 = switch (result) {
        .draw => 3,
        .loss => 0,
        .win => 6,
    };
    return resultScore;
}

fn getRoundScore(step: Step, result: Result) i8 {
    return getResultScore(result) + getStepScore(step);
}
pub fn main() !void {
    const file = try std.fs.cwd().openFile("data.txt", .{});
    defer file.close();

    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    const readFile = try file.readToEndAlloc(allocator, 512 * 512);
    defer allocator.free(readFile);

    var contentFile = std.mem.tokenizeAny(u8, readFile, "\n");

    var finalScore: i8 = 0;

    while (contentFile.next()) |item| {
        const iTakeStep: Step = try decryptStep(item[2]);
        const opponentTakeStep: Step = try decryptStep(item[0]);
        const result = getResult(iTakeStep, opponentTakeStep);

        finalScore += getRoundScore(iTakeStep, result);
    }

    std.debug.print("Final score {}\n", .{finalScore});
}

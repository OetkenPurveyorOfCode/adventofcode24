package main

import "core:fmt"
import "core:os"
import "core:mem"
import "core:strings"

fatalf :: proc(_fmt: string, args: ..any, flush := true) -> int {
    fmt.eprintf(_fmt, ..args, flush=flush)
    os.exit(-1)
}

main :: proc() {
    when ODIN_DEBUG {
		track: mem.Tracking_Allocator
		mem.tracking_allocator_init(&track, context.allocator)
		context.allocator = mem.tracking_allocator(&track)

		defer {
			if len(track.allocation_map) > 0 {
				fmt.eprintf("=== %v allocations not freed: ===\n", len(track.allocation_map))
				for _, entry in track.allocation_map {
					fmt.eprintf("- %v bytes @ %v\n", entry.size, entry.location)
				}
			}
			if len(track.bad_free_array) > 0 {
				fmt.eprintf("=== %v incorrect frees: ===\n", len(track.bad_free_array))
				for entry in track.bad_free_array {
					fmt.eprintf("- %p @ %v\n", entry.memory, entry.location)
				}
			}
			mem.tracking_allocator_destroy(&track)
		}
	}
	filename := "input.txt"
    data, ok := os.read_entire_file(filename, context.allocator)
    defer { delete(data) }
    if !ok {
        fatalf("ERROR: Could not read file `%s`\n", filename)
    }
    arena : mem.Dynamic_Arena
    mem.dynamic_arena_init(&arena, context.allocator)
    old_context_allocator := context.allocator
    context.allocator = mem.dynamic_arena_allocator(&arena)
    defer { mem.dynamic_arena_destroy(&arena) }
    
    it := string(data)
    grid: [dynamic][dynamic]u8
    for line in strings.split_lines_iterator(&it) {
        grid_line : [dynamic]u8
        for ch in line {
            fmt.printf("%v ", ch)
            append(&grid_line, u8(ch))
        }
        append(&grid, grid_line)
    }
    context.allocator = old_context_allocator

    fmt.printf("%c\n", grid)
    Vector2 :: [2]int
    directions := [8]Vector2{
        // x y, dy on x, dx on y
        Vector2{ 1,  0},
        Vector2{ 1,  1},
        Vector2{ 0,  1},
        Vector2{-1,  1},
        Vector2{-1,  0},
        Vector2{-1, -1},
        Vector2{ 0, -1},
        Vector2{ 1, -1},
    }
    match_count := 0
    for y in 0..<len(grid) {
        for x in 0..<len(grid[0]) {
            fmt.printf("%v %v\n", x, y)
            for dir in directions {
                matchee := [4]u8{0, 0, 0, 0}
                sx := x
                sy := y
                for i in 0..<len("XMAS") {
                    if (0 <= sx && sx < len(grid[0]) && 0 <= sy && sy < len(grid)) {
                        matchee[i] = grid[sy][sx]
                        sx += dir.x
                        sy += dir.y
                    }
                    else {
                        break;
                    }
                }
                fmt.printf("dir: %v matchee %s\n", dir, matchee);
                if mem.compare(matchee[:], []u8{'X', 'M', 'A', 'S'}) == 0{
                    fmt.printf("match\n")
                    match_count += 1
                }    
            }
        }
    }
    fmt.printf("xmas %v\n", match_count);
    cross_count := 0
    for y in 1..<(len(grid)-1) {
        for x in 1..<(len(grid[0])-1) {
            center_a := grid[y][x] == 'A'
            // NOTE forward and backward are analogous to forward and backward slash
            forward_mas := grid[y-1][x-1] == 'M' && grid[y+1][x+1] == 'S'
            forward_sam := grid[y-1][x-1] == 'S' && grid[y+1][x+1] == 'M'
            backward_sam := grid[y+1][x-1] == 'S' && grid[y-1][x+1] == 'M'
            backward_mas := grid[y+1][x-1] == 'M' && grid[y-1][x+1] == 'S'
            if (
                center_a 
                && (forward_sam || forward_mas)
                && (backward_sam || backward_mas)
            ) {
                cross_count += 1
            }
        }
    }
    fmt.printf("x-mas %v\n", cross_count);
}

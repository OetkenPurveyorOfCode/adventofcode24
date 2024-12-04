package main;

import "core:fmt"
import "core:os"
import "core:strings"
import "core:strconv"
import "core:sort"

main :: proc() {
    filename := "test.txt"
    data, ok := os.read_entire_file(filename, context.allocator);
    if !ok {
        fmt.eprintf("ERROR: Could not read file `%s`\n", filename)
        return
    }
    it := string(data);
    lefts: [dynamic]int
    rights: [dynamic]int
    for line in strings.split_lines_iterator(&it) {
        left : string = ""
        right : string = ""
        it2 := string(line)
        for split in strings.split_iterator(&it2, " ") {
            if split != "" {
                if left == "" {
                    left = string(split)
                }
                else if right == "" {
                    right = string(split)
                }
                else {
                    fmt.eprintf("ERROR Too many columns in file (expected 2)\n");
                }
            }
        }
        ileft, ok1 := strconv.parse_int(left)
        if !ok1 {
            fmt.eprintf("ERROR: Could not parse `%s` as number\n", left)
        }
        append(&lefts, ileft)
        iright, ok2 := strconv.parse_int(right)
        if !ok2 {
            fmt.eprintf("ERROR: Could not parse `%s` as number\n", right)
        }
        append(&rights, iright)
    }
    sort.quick_sort(lefts[:])
    sort.quick_sort(rights[:])
    total_distance := 0
    tuples := soa_zip(left=lefts[:], right=rights[:])
    for tuple in tuples {
        total_distance += abs(tuple.left - tuple.right);
    }
    fmt.printf("Total distance %d\n", total_distance);

    similarity_score := 0
    for left in lefts {
        occurence_count := 0
        for right in rights {
            if right < left {
                continue;
            }
            else if right == left {
                occurence_count += 1
            }
            else {
                similarity_score += left * occurence_count
                break;
            }
        }
    }
    fmt.printf("Similarity score: %d\n", similarity_score);
    return
}

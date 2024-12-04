package main

import "core:fmt"
import "core:os"
import "core:strings"
import "core:strconv"
import "core:slice"

split_ascii_space_iterator :: proc(s: ^string) -> (res: string, ok: bool) {
    space := true
    begin : int
    end : int
    for i := 0; i < len(s); i += 1 {
        ch := s[i]
        if space {
            if !strings.is_space(rune(ch)) {
                space = false
                begin = i
            }
        }
        else {
            if strings.is_space(rune(ch)) {
                space = true
                end = i
                res = s[begin:end]
                s^ = s[end:]
                ok = true
                return
            }
        }
    }
    allspace := true
    for i:= begin; i < len(s); i += 1 {
        ch := s[i]
        if !strings.is_space(rune(ch)) {
            allspace = false
            break
        }
    }
    res = s[begin:]
    ok = !allspace
    s^ = s[len(s):]
    return
}

fatalf :: proc(_fmt: string, args: ..any, flush := true) -> int {
    fmt.eprintf(_fmt, ..args, flush=flush)
    os.exit(-1)
}

is_report_safe :: proc(report : []i64) -> bool {
    safe := true
    all_decreasing := false
    all_increasing := false
    for r_it in 1..<len(report) {
        if (abs(report[r_it-1] - report[r_it]) > 3) {
            safe = false
            break
        }
        else if report[r_it-1] < report[r_it] {
            if (all_decreasing) {
                safe = false
                break
            }
            else {
                all_increasing = true
            }
        }
        else if report[r_it-1] > report[r_it]{
            if (all_increasing) {
                safe = false
                break
            }
            else {
                all_decreasing = true
            }
        }
        else /* equal */ {
            safe = false
            break
        }
    }
    fmt.printf(" %v %v\n", report, safe);
    return safe
}

main :: proc() {
    filename := "input.txt"
    b := true // Toggle between a and b solutions
    data, ok := os.read_entire_file(filename, context.allocator);
    if !ok {
        fatalf("ERROR: Could not read file `%s`\n", filename)
        return
    }
    it := string(data);
    reports: [dynamic][dynamic]i64
    defer delete(reports)
    for line in strings.split_lines_iterator(&it) {
        it2 := string(line)
        report: [dynamic]i64
        for split in split_ascii_space_iterator(&it2) {
            level, parse_ok := strconv.parse_i64(split)
            if !parse_ok {
                fatalf("ERROR: Could not parse `%s` as number\n", split)
            }
            append(&report, level)
        }
        append(&reports, report)
    }
    safe_count := 0
    for report in reports {
        if is_report_safe(report[:]) {
            safe_count += 1;
        }
        else if b {
            for i in 0..<len(report) {
                skipped_report := slice.concatenate([][]i64{report[:i], report[i+1:]}, context.allocator)
                defer {delete(skipped_report)}
                if is_report_safe(skipped_report[:]) {
                    safe_count += 1
                    break
                }
            }
        }
        else {}
    }
    fmt.printf("Number of safe reports: %v\n", safe_count);
    free_all(context.allocator)
}

package main

import "core:fmt"
import "core:os"
import "core:slice"

fatalf :: proc(_fmt: string, args: ..any, flush := true) -> int {
    fmt.eprintf(_fmt, ..args, flush=flush)
    os.exit(-1)
}

main :: proc() {
    filename := "input.txt"
    b := true // Toggle between a and b solutions
    data, ok := os.read_entire_file(filename, context.allocator);
    if !ok {
        fatalf("ERROR: Could not read file `%s`\n", filename)
        return
    }
    total_sum := 0
    mul_enabled := true
    for it := 0; it < len(data); it += 1 {
        if mul_enabled && slice.has_prefix(data[it:], transmute([]u8)string("mul(") ) {
            it += 4
            num1 := 0
            for it < len(data) && '0' <= data[it] && data[it] <= '9' {
                num1 *= 10
                num1 += int(data[it] - '0')
                it += 1
            }
            if data[it] != ',' {
                continue;
            }
            it += 1
            num2 := 0
            for it < len(data) && '0' <= data[it] && data[it] <= '9' {
                num2 *= 10
                num2 += int(data[it] - '0')
                it += 1
            }
            if (data[it] != ')') {
                continue;
            }
            total_sum += num1*num2;
        }
        else if b && slice.has_prefix(data[it:], transmute([]u8)string("don't")) {
            it += 5
            mul_enabled = false
        }
        else if b && slice.has_prefix(data[it:], transmute([]u8)string("do")) {
            it += 2
            mul_enabled = true
        }
        else {}
    }
    fmt.printf("Total sum %v\n", total_sum);
}

# fib

An x64 assembly program that prints the Fibonacci sequence up to a given number.

## Building

Use this shell function to build and link for x64 Linux:

```sh
function asm() { nasm -felf64 -g $1.asm && gcc $1.o -o $1 -no-pie }
```

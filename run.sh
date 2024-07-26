#!/bin/bash

# Default command
command="qemu-aarch64 -L /usr/aarch64-linux-gnu app"

# Process command line arguments
while getopts ":dsm" opt; do
  case $opt in
    d)
      # If -d flag is provided, modify the command to include debugging options
      command="qemu-aarch64 -L /usr/aarch64-linux-gnu -g 1234 app"
      ;;
    s)
      # If -s flag is provided, set up debugging with GDB
      gdb-multiarch -q --nh -ex 'set architecture aarch64' -ex 'file app' -ex 'target remote localhost:1234' -ex 'layout split' -ex 'layout regs'
      exit 0
      ;;
    m)
      aarch64-linux-gnu-gcc main.c -o main -g
      clear
      qemu-aarch64 -L /usr/aarch64-linux-gnu main
      exit 0
      ;;
    \?)
      echo "Invalid option: -$OPTARG" >&2
      exit 1
      ;;
  esac
done

# Assemble the source file
aarch64-linux-gnu-as -g -o app.o app.s

# Link the object file and create the executable
aarch64-linux-gnu-ld -o app app.o -lc

# Run the executable using QEMU or debug with GDB based on the command set
eval "$command"

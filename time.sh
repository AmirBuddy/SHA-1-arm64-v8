#!/bin/bash

# # Compile assembly code
# aarch64-linux-gnu-as -g -o app.o app.s
# aarch64-linux-gnu-ld -o app app.o -lc

# # Compile C code
# aarch64-linux-gnu-gcc main.c -o main -g

# Number of iterations
iterations=100

# Function to calculate average time
calculate_average() {
    total_time=$1
    avg_time=$(echo "scale=6; $total_time / $iterations" | bc)
    echo $avg_time
}

echo "Running assembly code..."
total_time_assembly=0
for ((i=1; i<=$iterations; i++))
do
    time_assembly=$( { time -p qemu-aarch64 -L /usr/aarch64-linux-gnu app; } 2>&1 | grep real | awk '{print $2}')
    total_time_assembly=$(echo "$total_time_assembly + $time_assembly" | bc)
done
avg_time_assembly=$(calculate_average $total_time_assembly)
echo "Assembly code average time: $avg_time_assembly seconds"

echo "Running C code..."
total_time_c=0
for ((i=1; i<=$iterations; i++))
do
    time_c=$( { time -p qemu-aarch64 -L /usr/aarch64-linux-gnu main; } 2>&1 | grep real | awk '{print $2}')
    total_time_c=$(echo "$total_time_c + $time_c" | bc)
done
avg_time_c=$(calculate_average $total_time_c)
echo "C code average time: $avg_time_c seconds"

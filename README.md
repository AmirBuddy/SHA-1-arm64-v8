# ARM64 SHA-1 Implementation

This project involves rewriting the SHA-1 encryption algorithm from C to ARM64-v8 assembly. The original C implementation (`FOO.c`) was cleaned up and commented to produce `main.c`, which served as the basis for the assembly version (`app.s`). The project demonstrates a deep understanding of SHA-1, ARM64 assembly, and various tools and techniques used in the development process.

## Folder Structure

```
.
├── app.s # ARM64 assembly implementation of SHA-1
├── FOO.c # Original C implementation of SHA-1
├── main.c # Cleaned and commented C implementation
├── run.sh # Bash script for building and running the project
└── time.sh # Bash script for timing the execution (if applicable)
```

## Description

- `FOO.c`: The original SHA-1 implementation in C.
- `main.c`: Cleaned-up version of `FOO.c` with comments for clarity.
- `app.s`: Optimized SHA-1 implementation in ARM64 assembly.
- `run.sh`: Bash script to assemble, link, run, and debug the assembly code using QEMU and GDB.
- `time.sh`: Script to measure execution time (if necessary).

## Features

- SHA-1 encryption algorithm implemented in both C and ARM64 assembly.
- Improved performance through assembly-level optimization.
- Use of QEMU for ARM64 emulation.
- Professional debugging setup using GDB.
- Makefile and Bash scripting for automated build and run processes.

## Learning Outcomes

- Understanding of SHA-1 encryption and encryption algorithms in general.
- Deep knowledge of ARM64 assembly language.
- Experience with QEMU and GDB for emulation and debugging.
- Familiarity with Makefile and Bash scripting for project automation.

## Usage

### Running the Assembly Code

1. **Default Run**: Execute the assembly code using QEMU.
    ```sh
    ./run.sh
    ```

2. **Debug Mode**: Run the assembly code with debugging options enabled.
    ```sh
    ./run.sh -d
    ```

3. **Setup Debugging with GDB**: Setup debugging environment using GDB.
    ```sh
    ./run.sh -s
    ```

4. **Compile and Run C Code**: Compile and run the cleaned-up C code.
    ```sh
    ./run.sh -m
    ```

### Assembling, Linking, and Running

The `run.sh` script handles the following steps:

1. Assemble the ARM64 assembly source file:
    ```sh
    aarch64-linux-gnu-as -g -o app.o app.s
    ```

2. Link the object file and create the executable:
    ```sh
    aarch64-linux-gnu-ld -o app app.o -lc
    ```

3. Run the executable using QEMU or debug with GDB based on the command-line options.

## Debugging

To debug the assembly code, use the `-d` flag with `run.sh` to start QEMU in debugging mode, and then use the `-s` flag to setup GDB for debugging:
```sh
./run.sh -d   # Start QEMU in debugging mode
./run.sh -s   # Setup GDB for debugging
```

## Bash Scripting

- **run.sh**: Automates the process of assembling, linking, running, and debugging the assembly code.
- **time.sh**: (Optional) Measures the execution time of the program. You can modify and use this script as needed.

## Conclusion

This project demonstrates the implementation and optimization of the SHA-1 algorithm in ARM64 assembly, providing insights into low-level programming, performance optimization, and the use of development tools like QEMU and GDB. The project setup, along with the provided scripts, allows for easy building, running, and debugging of the code.

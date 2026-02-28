# I2C Master IP - UVM Verification Environment

## Overview
This repository contains a complete, from-scratch **Universal Verification Methodology (UVM)** testbench designed to verify an I2C Master IP. The environment is heavily focused on **Coverage-Driven Verification (CDV)** and **Assertion-Based Verification (ABV)**, successfully achieving 100% functional coverage against the I2C protocol specification.

## Architecture
The testbench utilizes a standard UVM layered architecture:
* **Sequencer & Driver:** Capable of generating robust traffic, from single-byte pings to 120+ byte back-to-back read/write bursts.
* **Monitor:** Implements edge-sensitive `valid/ready` handshake sampling to ensure cycle-accurate data capture and seamless handling of asynchronous aborted transactions.
* **Scoreboard:** Dynamically models the internal memory of the Slave device, accurately predicting pointer increments, Repeated Starts, and Data/Address NACKs without throwing false failures.
* **Coverage Subscriber:** Tracks comprehensive cross-coverage between addressing types (Target, General Call), burst lengths, and NACK generations.

## Key Features
* **100% Functional Coverage:** Verified via rigorous regression testing.
* **Protocol Watchdogs (SVAs):** The `i2c_m_if.sv` interface includes concurrent SystemVerilog Assertions to actively monitor the physical bus for illegal `SDA` transitions while `SCL` is high, and checks for floating `X` or `Z` states.
* **Advanced Error Handling:** The environment gracefully handles Protocol NACKs, out-of-bounds memory access attempts, and General Call addressing.

## Notable Bugs Discovered & Resolved
During development, this environment successfully caught and resolved several complex edge cases:
1. **The "Ghost FSM" NACK:** Identified a non-blocking assignment (`<=`) race condition in the Slave BFM where the internal state machine evaluated the Read/Write status of the *previous* transaction, causing it to illegally NACK a General Call.
2. **"Late-Shutter" Monitor Misalignment:** Debugged a timing issue where the Monitor sampled data one clock cycle after the `valid/ready` handshake dropped, resulting in empty arrays. Resolved by implementing an active `while(1)` edge-evaluation loop.
3. **Scoreboard Memory Desync:** Fixed an issue where the Scoreboard blindly incremented its memory pointer on the final byte of a Read burst, drifting out of sync with the physical Slave RTL which freezes on a Master NACK.

# FPGA-Based-Hardware-Accelerator

![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)

This project accelerates 2D convolution for CNNs on FPGAs using the GEMM algorithm...

# Hardware-Acceleration-of-2D-Convolution-using-GeMM-Algorithm-on-FPGA

This repository implements **2D convolution on FPGAs using GEMM (im2col)** across:
- **Spartan-7 “Boolean” board** (XC7S50CSGA324-2)
- **Zynq UltraScale+ ZCU104** (XCZU7EV-FFVC1156-2-E)

It covers **full-frame**, **segmented-frame (striped)**, and **multi-kernel** modes, all under a clean **FSM-driven dataflow** called **IPICU** (Integrated Patchwise IM2COL Convolutional Unit).  

The pipeline runs **end-to-end**: input image (SD) → PL convolution → UART output → visualization(on local system).

---

## 📌 Overview

- **Motivation:** CPUs/GPUs struggle for real-time, low-power inference at the edge. FPGAs allow custom parallelism and efficient dataflows for CNN convolutions.
- **Key Idea:** Lower convolution to **matrix multiplication (im2col)**.  
  - Each 3×3 patch → a length-9 vector  
  - Kernel → a length-9 vector  
  - GEMM multiplies `49284×9` by `9×1` → reshaped back into a **222×222** output map  
- **Modes:**
  - **Full-frame:** sequential, minimal resource usage
  - **Segmented-frame:** image split into horizontal stripes, each handled by a dedicated PE
  - **Multi-kernel:** several kernels processed in parallel

---

## ⚙️ Assumptions & Defaults
- Input: **224×224** grayscale, 8-bit pixels(any NxN graycale image is supported)
- Kernel: **3×3**, signed 9-bit coefficients
- Stride: **1**
- Padding: **valid** → output size **222×222** (49,284 patches)
- Output: normalized/clipped to [0,255]
- Sofware simulations are done on Vitis sofware but documentations are not available
---

## 🛠️ Tools & Hardware
- **Xilinx Vivado** → RTL design (IPICU, FSM, BRAM, MAC, UART)
- **MATLAB** → visualization, reference checks
- **Boards:**
  - Spartan-7 Boolean board (100 MHz PL)
  - ZCU104 Zynq UltraScale+ (125 MHz PL/PS)

## 📊 Benchmarks

### PS vs PL (Full-frame)
| Platform           | Freq | Cycles     | Time (ms) |
|--------------------|------|------------|-----------|
| ZedBoard PS        | 100M | –          | ~52       |
| Zynq US+ PS        | 125M | 7,479,565  | 59.84     |
| PL (Boolean)       | 100M | 1,971,804  | 19.72     |
| PL (ZCU104)        | 125M | 1,971,804  | 15.77     |

➡️ ~3× faster in PL than PS.

---

### Segmented vs Full-frame

**Spartan-7 Boolean (100 MHz)**  
| Mode         | Time (ms) | LUTs | BRAM | DSP | Power (W) |
|--------------|-----------|------|------|-----|-----------|
| Full-frame   | 19.718    | 458  | 48.5 | 11  | 0.093     |
| Segmented (8)| 1.8       | 3631 | 56   | 88  | 0.225     |

**ZCU104 (125 MHz)**  
| Mode          | Time (ms) | LUTs | BRAM | DSP | Power (W) |
|---------------|-----------|------|------|-----|-----------|
| Full-frame    | 15.7744   | 1170 | 46   | 11  | 0.62      |
| Segmented (16)| 0.9947    | 6089 | 64   | 176 | 0.842     |

➡️ 10–16× faster with segmentation, at higher LUT/DSP/BRAM & dynamic power.

---

### Multi-kernel (ZCU104, K=6 vs K=1, Full-frame)
| Kernels | Time (ms) | LUTs | BRAM  | DSP | Power (W) |
|---------|-----------|------|-------|-----|-----------|
| 1       | 15.7744   | 1170 | 46    | 11  | 0.62      |
| 6       | 15.7744   | 1549 | 213.5 | 56  | 0.792     |

➡️ Same latency, **6× throughput**; resource use grows.

---

## 🔍 FSM & Dataflow (IPICU)

- **States:** IDLE → V-sliding → H-sliding → Patch Processing → Delay×2 → Store → Jump → Done.
- Handles address gen, patch buffering, BRAM latency, and output write-back.
- Scalable to larger M×N images, more kernels, or RGB channels by replicating/expanding MACs.

---

## 💡 Notes & Tips
- **Accumulator:** Use ≥21-bit signed accumulator (8+9+log₂9).
- **Memory traffic:** Line buffers + sliding windows reduce redundant reads.
- **DMA:** AXI DMA/AXI-Stream can cut PS overhead.
- **Scaling up:** Extend to RGB, larger kernels, padding modes, or Winograd transform.
- **Energy:** Static power dominates; dynamic scales with parallelism.

---

## 📌 Conclusions
- **Full-frame PL**: ~3× speedup over PS, lowest resource cost.  
- **Segmented-frame PL**: 10–16× faster, higher power/resources.  
- **Multi-kernel PL**: Throughput scales with kernels, latency unchanged.  

Choose **segmentation** for real-time needs, **multi-kernel** for high throughput, **full-frame** for efficiency.


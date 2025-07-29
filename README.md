# A Custom Hardware Accelerator for Image Segmentation Using U-Net for Autonomous Driving Applications
> This repository contains the IP the team EBREAKers submitted to [DVCON25-India](https://dvcon-india.org/invite-for-global-design-contest/) </br>
> Team members: [@NilupuleeA](https://github.com/NilupuleeA), [@pasiramavishan](https://github.com/pasiramavishan), [@yasith46](https://github.com/yasith46)

Our goal is to accelerate real-time semantic image segmentation for autonomous navigation applications using a U-Net-based deep learning model by using a hardware solution. This accelerator can be integrated with an SoC using AXI-lite interface. Currently, the IP is designed to do the following stages in an `int8` quantised U-Net.
- Stage 9 transpose convolution  (64x64x16    → 128x128x8)
- Stage 9 convolution            (128x128x16  → 128x128x8)
- Stage 10 convolution           (128x128x8   → 128x128x16)

The model that the IP was developed for can be found in [`dvcon25-unet-for-self-driving-cars.ipynb`](https://github.com/yasith46/self_driving_unet_custom_ip/blob/main/unet_model/kaggle/dvcon25-unet-for-self-driving-cars.ipynb). 


## 🔧 Integration Notes

This IP is designed to be SoC-agnostic and can be integrated with **any system that meets the following conditions**:

- Supports an **AXI-Lite** interface (32-bit data width)
- Has access to **external DDR memory** for input/output/weights
- Can control or configure the IP through memory-mapped registers

The IP was originally designed to be integrated with the [VEGA AT1051](https://vegaprocessors.in/at1051.php) 32-bit SoC by C-DAC, and implemented on a Diligent [Genesys 2](https://digilent.com/reference/programmable-logic/genesys-2/start?srsltid=AfmBOoqrqIJ6wbkXItR9lRKuxhnJjFpIYJJylS0GJwnBwziyw-QI9ohb) board.

> [!NOTE]
> The IP has not been optimised yet

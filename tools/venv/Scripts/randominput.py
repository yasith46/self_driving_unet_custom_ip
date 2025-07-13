import random

num_values = 98369

with open("inputdata.mem", "w") as f:
    for _ in range(num_values):
        val = random.getrandbits(32)  # Generate a random 32-bit integer
        f.write(f"{val:08X}\n")       # Write as 8-digit uppercase hex

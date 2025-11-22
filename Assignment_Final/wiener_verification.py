# No external dependencies needed!

print("=" * 60)
print("WIENER FILTER CALCULATION")
print("=" * 60)

# --- INPUT SECTION ---

# Read desired signal from user (space-separated numbers, no commas)
desired_str = input("Enter desired signal samples:\n> ")
desired = [float(x) for x in desired_str.split()]

# Read noise signal from user (space-separated numbers, no commas)
noise_str = input("\nEnter noise samples:\n> ")
noise = [float(x) for x in noise_str.split()]

# Basic validation
if len(desired) != len(noise):
    print("\nError: 'desired' and 'noise' must have the same number of samples.")
    print(f"Desired length: {len(desired)}, Noise length: {len(noise)}")
    exit(1)

# Calculate input signal x = d + w
input_signal = [d + w for d, w in zip(desired, noise)]

print("\nInput Data:")
print(f"Desired signal (d): {desired}")
print(f"Noise (w):          {noise}")
print(f"Input signal (x):   {input_signal}")

# --- Q1 FORMAT CALCULATIONS (like your original script) ---

print("\n" + "=" * 60)
print("Q1 FORMAT CALCULATIONS (MIPS Method)")
print("=" * 60)

# Convert to Q1 format (multiply by 10)
desired_q1 = [int(d * 10) for d in desired]
input_q1 = [int(x * 10) for x in input_signal]

print(f"\nDesired signal (Q1): {desired_q1}")
print(f"Input signal (Q1):   {input_q1}")

# Calculate sum_dx and sum_xx in Q1
sum_dx_q1 = sum(d * x for d, x in zip(desired_q1, input_q1))
sum_xx_q1 = sum(x * x for x in input_q1)

print(f"\nStep 1: Calculate sums")
print(f"  sum(d[i] * x[i]) = {sum_dx_q1}")
print(f"  sum(x[i] * x[i]) = {sum_xx_q1}")

# Calculate h in Q16.16 format: h = (sum_dx << 16) / sum_xx
if sum_xx_q1 != 0:
    sum_dx_shifted = sum_dx_q1 << 16
    h_q16_16 = sum_dx_shifted // sum_xx_q1
else:
    h_q16_16 = 0

print(f"\nStep 2: Calculate Wiener coefficient h")
print(f"  h (Q16.16 format) = {h_q16_16}")
print(f"  h (hex) = 0x{h_q16_16:08x}")
print(f"  h (as decimal) = {h_q16_16 / 65536.0:.6f}")

# Calculate output signal: y[i] = (h * x[i]) >> 16
print(f"\nStep 3: Calculate filtered output y[i] = (h * x[i]) >> 16")
output_q1 = []
for i, x in enumerate(input_q1):
    product = h_q16_16 * x
    y_q1 = product >> 16
    output_q1.append(y_q1)
    print(f"  y[{i}] = ({h_q16_16} * {x}) >> 16 = {y_q1} (= {y_q1/10.0:.1f})")

print(f"\nOutput signal (Q1): {output_q1}")

# Calculate MMSE: sum((d[i] - y[i])^2) / N  (keep same logic but generalize N)
print(f"\nStep 4: Calculate MMSE")
sum_e2 = 0
for i, (d, y) in enumerate(zip(desired_q1, output_q1)):
    error = d - y
    error_squared = error * error
    sum_e2 += error_squared
    print(f"  e[{i}] = {d} - {y} = {error}, e²[{i}] = {error_squared}")

N = len(desired_q1)
print(f"\n  sum(e²) = {sum_e2}")
mmse_q2 = sum_e2 // N
print(f"  MMSE (Q2 format) = {mmse_q2}")
print(f"  MMSE (as decimal) = {mmse_q2 / 100.0:.4f}")

# Final output
print("\n" + "=" * 60)
print("RESULT")
print("=" * 60)
print("Filtered output: ", end="")
for y in output_q1:
    print(f"{y / 10.0:.1f} ", end="")
print()
print(f"MMSE: {mmse_q2 / 100.0:.1f}")
print("=" * 60)

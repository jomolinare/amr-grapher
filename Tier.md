# Usage Tiers #

Many, if not most or all, electric companies charge based on tiered usage. My company uses the following Tiers and "break points":
  * Tier 1 = 0-500 kWh
  * Tier 2 = 501-1000 kWh
  * Tier 3 = 1000 kWh or greater

Each tier is charged at an increasing rate. These rates are easily changed in the sketch. However, the tier "break points" listed above are currently hard coded into the sketch. I hope to make this user modifiable in the future since I'm guessing that different companies have different tier break points.

If you're familiar with Processing or code you can edit the code to reflect your own tier break points on the "Calcs" tab of the sketch, in the calculateBilling() function.
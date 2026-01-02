# Multi-series or Parallel Univariate Series

Consider we have three variables -- A, B, and C.
Now, we may want to throw an anomaly when either of these is too-high or too-low against the trend and seasonality. 
For instance, consider the three cases:
1. A is too high, B is fine, C is fine. **Flagged**
2. A is fine, B is too high, C is fine. **Flagged**
3. A is fine, B is fine, C is too high. **Flagged**

It wouldn't be flagged if all three are fine:
A is fine, B is fine, C is fine. **Not flagged**

It is great if our usecase is such but has its own blindspots:
*What if A is fine, B is fine, C is fine, but there exact combination with such values is problematic?*

Through this, we realize that a multi-series model doesn't cover **combinations**, in a standard sense - **correlation** between the variables. In such a case, a multivariate model is required which considers correlation as well.
Note: The anomaly detection scripts/code provided here were applied to time-series.
*** 

### Time series
A time-series is a sequence of data points collected in a chronological order at successive and typically fixed intervals.
Time-series are often decomposed into three components:
1. Trend: The 'up' or 'down' direction of the data over a time period. For eg. the rising of global temperatures lately.
2. Seasonality: The seasonal 'up' or 'down'which is predictable. For eg. increased sales of a clothing shop during weekends.
3. Noise: Random unpredicted spike or downfall.

### Dimensionality
Time-series have dimensionality i.e. how many variables/metrics are involved. For instance, for a clothing shop, a single variable may be enough, i.e. sales. So the time series would be 1D with two columns (timestamp, sales). Others may have more dimensions included. For instance, an air quality dataset may include metrics of concetration of many gases at any instance (timestamp, concetration(NO2), concentration(CO2)....).
Therefore they are categorized into two major categories: Univariate and Multivariate. 

### The Real World
During analysis and ML implementation however, there is no clear binary classification. For instance, sometimes, out of many dimensions we may be interested in one variable but others may be needed for context. For eg. we may be interested in room temperature but it can only be judged against the outside temperature indicating conditions. This divides the variables into Endogenous (Primary - room temperature), and Exogenous (for context - outside temperature).
In other cases, all (or more than one) variables may carry an equal weight. For instance, in air quality index. So we can see that things can get complex and even more complex while interaction with the real world.
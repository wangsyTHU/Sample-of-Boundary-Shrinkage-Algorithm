# Sample Case of Boundary Shrinkage Algorithm 

## Requirement
- MATLAB
- [YALMIP](https://yalmip.github.io/)
- [GUROBI](https://www.gurobi.com/) solver

## Usage

This case demonstrates the boundary shrinkage algorithm, which is used to aggregate the flexibility of a cluster of diverse generators. The aggregation results define the upper and lower bounds for both power and ramp rates of the equivalent generator.

To run the algorithm, execute `main.m`.

The core algorithm (standard version) is implemented in `boundShrinkStd.m`, following the exact methodology and variable symbols described in the paper. An accelerated version is available in `boundShrink.m`, which enhances computational efficiency, enabling the handling of higher-dimensional problems.

## Reference

S. Wang and W. Wu, “[Aggregate Flexibility of Virtual Power Plants with Temporal Coupling Constraints](https://ieeexplore.ieee.org/document/9520661),” IEEE Transactions on Smart Grid, vol. 12, no. 6, pp. 5043-5051, Nov. 2021, doi: 10.1109/TSG.2021.3106646.
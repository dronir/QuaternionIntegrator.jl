
# QuaternionIntegrator.jl

[![Build Status](https://travis-ci.org/dronir/QuaternionIntegrator.jl.svg?branch=master)](https://travis-ci.org/dronir/QuaternionIntegrator.jl)
[![codecov](https://codecov.io/gh/dronir/QuaternionIntegrator.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/dronir/QuaternionIntegrator.jl)

Simple integrator for orientation quaternions. Given an orientation quaternion, initial
angular velocity, an inertial tensor and a function that gives torque as a function of
orientation, this package allows you to compute the time evolution of the orientation.

Currently relatively untested (despite the code coverage) and I have no idea of the
accuracy of the algorithm.



## Quick start

```
using Quaternions
using QuaternionIntegrator

# Constant torque around y axis
torque(q) = [0.0, 1.0, 0.0]

# Simplest diagonal inertial tensor
I = diagm([1.0, 1.0, 1.0])

# Starting orientation
q0 = orientation([0.0, 1.0, 0.0], π/2)

# Starting angular velocity (not rotating)
ω0 = [0.0, 0.0, 0.0]

# Integration time step
∆t = 0.01

# Get orientation and angular velocity after one timestep
q1, ω1 = integrate(q0, ω0, I, ∆t, torque)

# Compute 1000 time steps ahead
qn, ωn = integrate(q0, ω0, I, ∆t, torque, 1000)
```



# QuaternionIntegrator.jl

[QuaternionIntergrator.jl](https://github.com/dronir/QuaternionIntegrator.jl) is a
[Julia](https://julialang.org) package that lets you compute the time evolution of an
object's rotational state, given its inertial tensor and an external torque function.

Based on the algorithm given by F. Zhao and B. G. M. van Wachem (2013) _A novel Quaternion
integration approach for describing the behaviour of non-spherical particles_, Acta Mech
224, 3091–3109.

The orientation of the object is represented as a standard rotation quaternion: given a
unit vector along a rotational axis ``\mathbf v`` and an angle around that axis ``\theta``,
the quaternion is

```math
q = \left(\cos \frac{\theta}{2}, \sin \frac{\theta}{2} \mathbf v \right).
```

This quaternion represents a rotation from body-fixed coordinates to world coordinates.

## Quick start

```@example
using Quaternions, QuaternionIntegrator, LinearAlgebra

# Constant torque around y axis
torque(q) = [0.0, 1.0, 0.0]

# Simplest diagonal inertial tensor
I = diagm([1.0, 1.0, 1.0])

# Starting orientation (no rotation)
q0 = Quaternion(1.0, 0.0, 0.0, 0.0)

# Starting angular velocity (not rotating)
ω0 = [0.0, 0.0, 0.0]

# Integration time step
∆t = 0.01

# Get orientation and angular velocity after one timestep
q1, ω1 = integrate(q0, ω0, I, ∆t, torque)

# Compute 1000 time steps ahead
qn, ωn = integrate(q0, ω0, I, ∆t, torque, 1000)
```

## Now supporting Unitful.jl

If [Unitful.jl](https://github.com/PainterQubits/Unitful.jl) units are provided for the
inputs, the output will have correct units. This has a minor effect on performance.

```@example
using Quaternions, QuaternionIntegrator, Unitful, LinearAlgebra
∆t = 10000.0 * u"µs"
I = diagm([1.0, 1.0, 1.0]) * u"kg * m^2"
torque(q) = [0.0, 1000.0, 0.0] * u"N * mm"
q0 = Quaternion(1.0, 0.0, 0.0, 0.0)
ω0 = [0.0, 0.0, 0.0] * u"1/s"
q1, ω1 = integrate(q0, ω0, I, ∆t, torque, 1000)
```

## Now also supporting StaticArrays.jl

Now you can also give your torque function output, your angular velocity vector, and
your inertial tensor as [StaticArrays](https://github.com/JuliaArrays/StaticArrays.jl).
This will result in a considerable speedup of the code. In my testing, a simulation that
took 5–6 minutes with Julia arrays, only took 30 seconds with static arrays.

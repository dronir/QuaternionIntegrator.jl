
# QuaternionIntegrator.jl

Simple integrator for orientation quaternions. Given an orientation quaternion, initial
angular velocity, an inertial tensor and a function that gives torque as a function of
orientation, this package allows you to compute the time evolution of the orientation.

Currently untested and I have no idea of the accuracy.



## Quick introduction

An orientation quaternion represents an axis and a rotation angle, and it maps from 
an objects body coordinate frame to the (inertial) world frame.

The package exports two functions: `rotate` and `integrate`. The latter has two methods.

### rotate(q, v)

This function applies the rotation quaternion `q` to the vector `v` and returns the
resulting rotated vector. If `q` describes an object's orientation in the world coordinate
frame, the function maps a vector from body-fixed coordinates to world coordinates.

### integrate(q0::Quaternion, w0::Vector, Ib::Matrix, dt::Real, torque::Function)

This function takes in a quaternion `q0`, an angular velocity vector `w0`, an inertial
tensor `Ib`, the length of the time step `dt` and a function `torque` which returns a
torque vector, given an orientation.

The inertial tensor is given as a `(3,3)` matrix, which has the components of the inertial
tensor in the body coordinates.

The torque function `torque(q)` takes in an orientation quaternion and returns a 3-element
torque vector in world coordinates.

The function returns `(q1, w1)`, the orientation and angular velocity after the time step.

### integrate(q0::Quaternion, w0::Vector, Ib::Matrix, dt::Real, torque::Function, Nsteps::Integer)

As above, but computes `Nsteps` ahead in time, and returns arrays of orientation
quaternions and velocity vectors.

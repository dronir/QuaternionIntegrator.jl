module QuaternionIntegrator

using Quaternions
using LinearAlgebra
using Unitful
using StaticArrays

export rotate, orientation, integrate

import Unitful.unit
import Quaternions: imag, Quaternion


# Some utility functions to help make this package compatible with Unitful
unit(A) = unit(eltype(A))
@inline vec_quaternion(v) =  Quaternion(0.0, ustrip.(unit(v), v)) * unit(v)
imag(q::Quantity) = imag(ustrip(unit(q), q)) * unit(q)

# Quaternion from length-3 SVectors
Quaternion(s::Real, w::SArray{Tuple{3},T,1,3}) where T = Quaternion(s, w...)

# Quaternion from length-4 SVectors
Quaternion(w::SArray{Tuple{4},T,1,4}) where T = Quaternion(w...)


"""
    rotate(q::Quaternion, v)

Apply orientation quaternion `q` to rotate vector `v`, return rotated vector.

An object's orientation quaternion rotates vectors from the body-fixed coordinates to world
coordinates. For the opposite rotation, call `rotate(inv(q), v)`.

"""
rotate(q::Quaternion, v) = Quaternions.imag(q * vec_quaternion(v) * inv(q))

function rotate(q::Quaternion, v::SVector) 
    p = q * vec_quaternion(v) * inv(q)
    return SVector{3}(imag(p))
end



"""
    orientation(v::Vector, angle::Real)

Return an orientation quaternion with the given axis `v` and rotation angle.

The vector `v` is assumed to be normalized to unit length.

"""
function orientation(v, angle::Real)
    return Quaternion(cos(0.5 * angle), sin(0.5 * angle) .* v)
end


"""
    integrate(q0::Quaternion, ω0::Vector, Ib::Matrix, ∆t, torque::Function ; IbInv::Union{Nothing,AbstractArray} = nothing)

Integrate a rotational state ahead by one time step.

- `q0`, current orientation quaternion.
- `ω0`, current angular velocity (length-3 vector).
- `Ib`, inertial tensor of the object in body coordinates (3×3 matrix).
- `∆t`, length of time step.
- `torque`, a function that returns a (length-3) torque vector given an orientation. 
- `IbInv` is an optional parameter giving the inverse matrix of `Ib`. Providing it will speed up the computation slightly.

Returns `(q1, ω1)`, the orientation and angular velocity at the end of the time step.

Using the Unitful package, all inputs can have units, all the mathematics are done with
units and the return values will have correct units.

- `q0` is dimensionless.
- `ω0` has dimension of 1/time (SI: 1/second)
- `Ib` has dimension mass * length^2 (SI: kilogram * meter^2)
- `∆t` has dimension of time (SI: second)
- `torque` returns a value with dimension of torque (SI: Newton * meter)

"""
function integrate(q0::Quaternion, w0, Ib, dt, torque::Function ; IbInv::Union{Nothing,AbstractArray} = nothing)
    if IbInv === nothing
        IbInv = inv(Ib)
    end
    
    # Transform velocity and torque into body frame
    wb0 = rotate(inv(q0), w0)
    Tb0 = rotate(inv(q0), torque(q0))
    
    # Compute body-frame startpoint acceleration from torque
    wdb0 = IbInv * (Tb0 - cross(wb0, (Ib * wb0)))
    
    # Compute quarter-point body-frame velocity from startpoint velocity and acceleration
    wb4 = wb0 + 0.25 * wdb0 * dt
    
    # Compute midpoint body-frame velocity from startpoint velocity and acceleration
    wb2 = wb0 + 0.50 * wdb0 * dt
    
    # Rotate quarter-point velocity to world frame
    w4 = rotate(q0, wb4)
    n4 = norm(w4)
    
    # Compute (predicted) midpoint orientation from quarter-point velocity and startpoint orientation
    qp2 = Quaternion(cos(0.25 * n4 * dt), sin(0.25 * n4 * dt) * w4 / n4) * q0
    
    # Compute torque at predicted midpoint and rotate it to body frame
    Tb2 = rotate(inv(qp2), torque(qp2))
    
    # Compute body-frame midpoint acceleration from torque based on midpoint orientation
    wdb2 = IbInv * (Tb2 - cross(wb2, (Ib * wb2)))

    # Rotate (predicted) midpoint velocity to world frame
    w2 = rotate(qp2, wb2)
    n2 = norm(w2)
    
    # Compute endpoint orientation from midpoint velocity and startpoint orientation
    q1 = Quaternion(cos(0.5 * n2 * dt), sin(0.5 * n2 * dt) * w2 / n2) * q0

    # Apply midpoint acceleration to get endpoint velocity and rotate it to world frame
    wb1 = wb0 + wdb2 * dt
    w1 = rotate(q1, wb1)
    
    return q1, w1

end


"""
    integrate(q0::Quaternion, ω0::Vector, Ib::Matrix, ∆t, torque::Function, N::Integer)

Integrate a rotational state ahead by `N` time steps.

Returns `(q1, ω1)`, the orientation and angular velocity after `N` integration steps.

"""
function integrate(q0::Quaternion, w0, Ib, dt, torque::Function, Nsteps::Integer)
    IbInv = inv(Ib)
    for i = 1:Nsteps
        q0, w0 = integrate(q0, w0, Ib, dt, torque ; IbInv = IbInv)
    end
    return q0, w0
end


end # module


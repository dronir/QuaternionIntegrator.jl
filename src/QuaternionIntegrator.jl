module QuaternionIntegrator

using Quaternions
using LinearAlgebra

export rotate, integrate

@inline rotate(q::Quaternion, v) = Quaternions.imag(q * Quaternion(0.0, v) * inv(q))

dummy_torque(q) = [0.0, 0.0, 0.0]

function integrate(q0::Quaternion, w0::Vector, Ib::Matrix, dt::Real, torque::Function)
    
    # Transform velocity and torque into body frame
    wb0 = rotate(inv(q0), w0)
    Tb0 = rotate(inv(q0), torque(q0))
    
    # Compute body-frame startpoint acceleration from torque
    wdb0 = inv(Ib) * (Tb0 - cross(wb0, (Ib * wb0)))
    
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
    wdb2 = inv(Ib) * (Tb2 - cross(wb2, (Ib * wb2)))

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


function integrate(q0::Quaternion, w0::Vector, Ib::Matrix, dt::Real, torque::Function, Nsteps::Integer)
    Q = typeof(q0)[q0]
    W = typeof(w0)[w0]
    for i = 1:Nsteps
        q0, w0 = step(q0, w0, Ib, dt, torque)
        push!(Q, q0)
        push!(W, w0)
    end
    return Q, W
end


end # module


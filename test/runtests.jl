
using Test
using Quaternions
using QuaternionIntegrator
using LinearAlgebra

@testset "Rotation function" begin
    axis = [0.0, 0.0, 1.0]
    angle = π/4
    q = Quaternion(cos(angle/2), sin(angle/2) * axis)
    
    @test rotate(q, [1.0, 0.0, 0.0]) ≈ [sqrt(2)/2, sqrt(2)/2, 0.0]
    @test rotate(q, [0.0, 1.0, 0.0]) ≈ [-sqrt(2)/2, sqrt(2)/2, 0.0]
    @test rotate(q, [0.0, 0.0, 1.0]) ≈ [0.0, 0.0, 1.0]
end


@testset "Step" begin
    # Set up test
    
    ∆t = 0.001
    I = diagm([1.0, 1.0, 1.0])
    torque = QuaternionIntegrator.dummy_torque
    q0 = Quaternion(1.0, 0.0, 0.0, 0.0)
    w0 = [0.0, 0.0, 1.0]
    
    q1, w1 = integrate(q0, w0, I, ∆t, torque)
    
end


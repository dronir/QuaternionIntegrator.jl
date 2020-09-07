
using Test
using Quaternions
using QuaternionIntegrator
using LinearAlgebra
using Unitful
using StaticArrays

@testset "Rotation function" begin
    axis = [0.0, 0.0, 1.0]
    angle = π/4
    q = Quaternion(cos(angle/2), sin(angle/2) * axis)
    
    @test rotate(q, [1.0, 0.0, 0.0]) ≈ [sqrt(2)/2, sqrt(2)/2, 0.0]
    @test rotate(q, [0.0, 1.0, 0.0]) ≈ [-sqrt(2)/2, sqrt(2)/2, 0.0]
    @test rotate(q, [0.0, 0.0, 1.0]) ≈ [0.0, 0.0, 1.0]
end

@testset "Orientation function" begin
    v = [0.0, 0.0, 1.0]
    
    @test orientation(v, 0.0) ≈ Quaternion(1.0, 0.0, 0.0, 0.0)
    @test orientation(v, π/2) ≈ Quaternion(cos(π/4), 0.0, 0.0, sin(π/4))
    @test orientation(v, π) ≈ Quaternion(cos(π/2), 0.0, 0.0, sin(π/2))
    
end


@testset "Step" begin
    # Set up test
    
    ∆t = 0.001
    I = diagm([1.0, 1.0, 1.0])
    torque(q) = [0.1, 0.0, 0.0]
    q0 = Quaternion(1.0, 0.0, 0.0, 0.0)
    w0 = [0.0, 0.0, 1.0]
    
    q1, w1 = integrate(q0, w0, I, ∆t, torque)
    
end


@testset "Multi-step" begin

    # Set up tests
    ∆t = 0.001
    I = diagm([1.0, 1.0, 1.0])
    torque(q) = [0.1, 0.0, 0.0]
    q0 = Quaternion(1.0, 0.0, 0.0, 0.0)
    w0 = [0.0, 0.0, 0.0]
    N = 1
    
    q1, w1 = integrate(q0, w0, I, ∆t, torque)
    qn, wn = integrate(q0, w0, I, ∆t, torque, N)

    @test qn ≈ q1
    @test wn ≈ w1

end


@testset "Unitful" begin
    # 
    ∆t = 0.001 * u"s"
    I = diagm([1.0, 1.0, 1.0]) * u"kg * m^2"
    torque(q) = [0.1, 0.0, 0.0] * u"N * m"
    q0 = Quaternion(1.0, 0.0, 0.0, 0.0)
    w0 = [0.0, 0.0, 1.0] * u"1/s"
    
    q1, w1 = integrate(q0, w0, I, ∆t, torque)

    @test unit(q1) == NoUnits
    @test unit(w1) == unit(u"1/s")
end

@testset "Static Arrays" begin
    # Set up test
    
    ∆t = 0.001
    I = diagm([1.0, 1.0, 1.0])
    I = SMatrix{3,3}(I)
    torque(q) = SVector(0.1, 0.0, 0.0)
    q0 = Quaternion(1.0, 0.0, 0.0, 0.0)
    w0 = SVector(0.0, 0.0, 1.0)
    
    q1, w1 = integrate(q0, w0, I, ∆t, torque)
    @test typeof(w1) <: SArray
    
end

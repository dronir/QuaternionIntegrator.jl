
# The algorithm

The purpose of the algorithm is to take the current orientation ``q_0`` and angular
velocity ``\omega_0`` and produce the orientation ``q_1`` and angular velocity ``\omega_1``
after a time step ``\Delta t``.


## Orientation and coordinate frames

An object's orientation is a rotation between two coordinate frames: world coordinates and
body coordinates. The body frame is fixed to the object and rotates with it relative to the
world coordinates.

The orientation of the object is represented as a standard rotation quaternion: given a
unit vector along a rotational axis ``\mathbf v`` and an angle around that axis ``\theta``,
the quaternion is

```math
q = \left(\cos \frac{\theta}{2}, \sin \frac{\theta}{2} \mathbf v \right).
```

!!! note

    Quaternions are represented in this text as a pair ``(a, \mathbf v)`` of a real number
    and a 3-dimensional real-valued vector. Other equivalent representations exist but this
    one is the most useful here.

The orientation quaternion is used to transform vectors from body coordinates to world
coordinates and vice versa. Given a vector ``\mathbf v_b`` in body coordinates, and the
orientation ``q``, the rotation to world coordinates coordinates is the operation ``\mathbf
v = q \mathbf v_b q^{-1}``. The rotation from world coordinates to body coordinates is
simply the inverse, ``\mathbf v_b = q^{-1} \mathbf v q``.

!!! note

    We denote the rotation of a vector ``\mathbf v`` by a quaternion with ``q \mathbf v
    q^{-1}``. In practice, this operation involves constructing a new quaternion ``(0,
    \mathbf v)``, performing the quaternion multiplication and extracting the vector part
    of the resulting quaternion.

!!! note

    We denote vectors in the body coordinate frame with the subscript `b` and in the world
    coordinate with no subsript.

## Integration step

The algorithm is from F. Zhao and B. G. M. van Wachem (2013) _A novel Quaternion
integration approach for describing the behaviour of non-spherical particles_, Acta Mech
224, 3091–3109. For a full derivation and more detail, see the paper.

We begin with the initial orientation ``q_0``, initial angular velocity vector ``\mathbf
\omega_0``, which is the momentary rate of change of the orientation. We also have a torque
function ``T(q)`` which taken an orientation quaternion and returns a torque vector in
world coordinates, as well as the inertial tensor of the object, given in the body frame,
``I_b``.

!!! note

    We denote quantities at the beginning of the timestep with the subscript 0, at the end
    of the timestep with subscript 1. In the algorithm, also midpoint and quarter-point
    values are used and these are denoted with ``\frac{1}{2}`` and ``\frac{1}{4}``


First we transform the angular velocity vector to body coordinates:

```math
\mathbf \omega_{b,0} = q_0^{-1} \mathbf \omega_0 q.
```

We compute the torque in the initial orientation and transform the resulting torque vector
to the body frame.

```math
\tau_0 = T(q_0),
```

```math
\tau_{b,0} = q_0^{-1} \mathbf \tau_0 q.
```

The angular acceleration, in the body frame, is computed from the inertia and the torque:

```math
\dot\omega_{b,0} = I_b^{-1} \left( \tau_{b,0} - \omega_{b,0} \times I_b \omega_{b,0} \right)
```

Next, we compute angular velocity in the body frame after a quarter timestep and a half
timestep.

```math
\omega_{b,\frac{1}{4}} = \omega_{b,o} + \frac{1}{2} \dot\omega_{b,0} \Delta t
```

```math
\omega_{b,\frac{1}{2}} = \omega_{b,0} + \frac{1}{4} \dot\omega_{b,0} \Delta t
```

We rotate the quarter-point angular velocity to the world coordinates and use it to compute
a "prediction" for the half-point orientation quaternion.

```math
\omega_\frac{1}{4} = q_0 \omega_{b,\frac{1}{4}} q_0^{-1}
```

```math 
q_\frac{1}{2} = \left( \cos \left(\frac{1}{4} \left| \omega_\frac{1}{4} \right|
\Delta t \right), \sin \left( \frac{1}{4} \left| \omega_\frac{1}{4} \right| \Delta t
\right) \hat \omega_\frac{1}{4} \right) q_0
```

!!! note

    The hat represents a vector normalized to unit length.

This predicted midpoint orientation is then used to compute a torque and angular
acceleration at the midpoint:

```math
\tau_0 = T(q_\frac{1}{2}),
```

```math
\tau_{b,\frac{1}{2}} = q_0^{-1} \mathbf \tau_\frac{1}{2} q.
```

```math
\dot\omega_{b,\frac{1}{2}} = I_b^{-1} \left( \tau_{b,\frac{1}{2}} - \omega_{b,\frac{1}{2}} \times I_b \omega_{b,\frac{1}{2}} \right)
```

This midpoint acceleration is then used with the starting orientation to compute the
endpoint orientation

```math
\omega_\frac{1}{2} = q_\frac{1}{2} \omega_{b,\frac{1}{2}} q_\frac{1}{2}^{-1}
```

```math 
q_1 = \left( \cos \left(\frac{1}{2} \left| \omega_\frac{1}{2} \right|
\Delta t \right), \sin \left( \frac{1}{2} \left| \omega_\frac{1}{2} \right| \Delta t
\right) \hat \omega_\frac{1}{2} \right) q_0
```


Finally, the angular acceleration at the midpoint is used to compute the angular velocity
at the endpoint.

```math
\omega_{b,1} = \omega_{b,0} + \dot\omega_{b,\frac{1}{2}} \Delta t
```

```math
\omega_1 = q_1 \omega_{b,1} q_1^{-1}
```



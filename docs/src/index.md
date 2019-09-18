
# QuaternionIntegrator

Compute the time evolution of an object's rotational state, given its inertial tensor and
an external torque function.

Based on the algorithm given by F. Zhao and B. G. M. van Wachem (2013) _A novel Quaternion
integration approach for describing the behaviour of non-spherical particles_, Acta Mech
224, 3091–3109.

The orientation of the object is represented as a standard rotation quaternion: given a
unit vector along a rotational axis ``\mathbf v`` and an angle around that axis ``\theta``,
the quaternion is

```math
q = \left(\cos \frac{\theta}{2}, \sin \frac{\theta}{2} \mathbf v \right).
```

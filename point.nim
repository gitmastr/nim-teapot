import options
from math import sqrt, sin, cos

type 
    PointFloat* = float32
    Point* = object 
        x*, y*, z*: PointFloat
    Face* = object 
        p1*, p2*, p3*: Point
    Ray* = object
        base*, direction*: Point
    Bary* = object
        b1*, b2*, b3*: PointFloat

proc `+` *(p1, p2: Point): Point =
    result = Point(
        x: p1.x + p2.x,
        y: p1.y + p2.y,
        z: p1.z + p2.z)

proc cross *(p1, p2: Point): Point =
    result = Point(
        x: p1.y * p2.z - p1.z * p2.y,
        y: p1.z * p2.x - p1.x * p2.z,
        z: p1.x * p2.y - p1.y * p2.x
    )

proc rotx *(p: Point, f: float): Point =
    let
        c = cos(f)
        s = sin(f)
    result = Point(
        x: p.x,
        y: c * p.y - s * p.z,
        z: s * p.y + c * p.z
    )

proc roty *(p: Point, f: float): Point =
    let
        c = cos(f)
        s = sin(f)
    result = Point(
        x: c * p.x - s * p.z,
        y: p.y,
        z: c * p.z - s * p.x
    )

proc rotz *(p: Point, f: float): Point =
    let
        c = cos(f)
        s = sin(f)
    result = Point(
        x: c * p.x - s * p.y,
        y: s * p.x + c * p.y,
        z: p.z
    )

proc `+=` *(base: var Point, other: Point) =
    base.x += other.x
    base.y += other.y
    base.z += other.z

proc `-=` *(base: var Point, other: Point) =
    base.x -= other.x
    base.y -= other.y
    base.z -= other.z

proc `-` *(p1, p2: Point): Point =
    result = Point(
        x: p1.x - p2.x,
        y: p1.y - p2.y,
        z: p1.z - p2.z)

proc dot *(p1, p2: Point): PointFloat =
    result = p1.x * p2.x + p1.y * p2.y + p1.z * p2.z

proc `*` *(f: PointFloat, p: Point): Point = 
    result = Point(
        x: f * p.x,
        y: f * p.y,
        z: f * p.z
    )



proc norm *(p: Point): PointFloat =
    result = sqrt(p.dot(p))

proc square *(f: PointFloat): PointFloat =
    result = f * f

proc normalize *(p: Point): Point =
    result = (1.0 / p.norm) * p

proc normal *(f: Face): Point =
    result = (f.p2 - f.p1).cross(f.p3 - f.p1).normalize

proc intersectsFace *(r: Ray, f: Face): Option[Point] =
    let 
        n = f.normal.normalize
        d = n.dot(f.p1)

    # make sure we aren't inside plane
    if n.dot(r.direction) == 0:
        return

    let
        t = (d - n.dot(r.base)) / n.dot(r.direction)

    if t <= 0:
        return

    # otherwise, might be intersection

    let
        q = r.base + t * r.direction # intersection
        area = ((f.p2 - f.p1).cross(f.p3 - f.p1)).dot(n)
        b1 = (f.p3 - f.p2).cross(q - f.p2).dot(n) / area
        b2 = (f.p1 - f.p3).cross(q - f.p3).dot(n) / area
        b3 = (f.p2 - f.p1).cross(q - f.p1).dot(n) / area

    let test = b1 * f.p1 + b2 * f.p2 + b3 * f.p3
    # assert norm(test - q) < 0.0001

    if b1 >= 0 and b2 >= 0 and b3 >= 0:
        return some(q)
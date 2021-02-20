import point, strutils, options

type 
    Object* = object
        vertices: seq[Point]
        faces: seq[Face]

proc load *(filename: string): Object =
    var f: File
    var vertices: seq[Point]
    var faces: seq[Face]
    if open(f, filename):
        defer: close f
        for line in f.lines:
            let s = line.split(" ")
            if s[0] == "v":
                vertices.add(Point(
                    x: parseFloat(s[3]),
                    y: parseFloat(s[1]),
                    z: parseFloat(s[2])
                ))
            elif s[0] == "f":
                let
                    p1 = parseInt(s[1]) - 1
                    p2 = parseInt(s[2]) - 1
                    p3 = parseInt(s[3]) - 1
                faces.add(Face(
                    p1: vertices[p1],
                    p2: vertices[p2],
                    p3: vertices[p3]
                ))
                
    # echo "Loaded ", vertices.len, " vertices"
    # echo "Loaded ", faces.len, " faces"
    result = Object(
        vertices: vertices, 
        faces: faces
    )

proc move *(obj: var Object, d: Point) =
    for i in 0..<obj.vertices.len:
        obj.vertices[i] += d
    for i in 0..<obj.faces.len:
        obj.faces[i].p1 += d
        obj.faces[i].p2 += d
        obj.faces[i].p3 += d

proc intersectsRay *(obj: Object, r: Ray): Option[tuple[intersection, normal: Point]] =
    for i, f in obj.faces.pairs:
        let v = intersectsFace(r, f)
        if v.isSome:
            # if found closer collision
            if result.isNone or (v.get - r.base).norm < (result.get.intersection - r.base).norm:
                result = some((
                    intersection: v.get,
                    normal: f.normal
                ))
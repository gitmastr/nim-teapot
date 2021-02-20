import point, obj, nimPNG, sequtils, camera, math, options

const 
    WIDTH = 1280
    HEIGHT = 720

var teapot = load("teapot.obj")
teapot.move(Point(x: 0, y: 0, z: -1.3))

var rgb = newSeq[uint8](3 * WIDTH * HEIGHT)


let c = Camera(
    pos: Point(x: 5, y: 1, z: 2),
    tilt: -0.3,
    pan: PI / 2 + 0.17,
    fovMax: PI / 2
)

const sun = Point(x: 8, y: 8, z: 8)

var done = 0
var lastPercent = 0

for u, v, r in c.rays(WIDTH, HEIGHT):
    let 
        rgbidx = 3 * (u + v * WIDTH)
        collision = teapot.intersectsRay(r)
    
    var intensity = 90'u8
    if collision.isSome:
        let 
            colPoint = collision.get.intersection
            colNormal = collision.get.normal
            pointSunDist = norm(colPoint - sun)
            reflection = r.direction - 2.0 * colNormal.dot(r.direction) * colNormal
            p = reflection.dot(sun - colPoint) / (sun - colPoint).norm
        intensity = uint8(255 * (1 + p) / 2)

    rgb[rgbidx + 0] = intensity
    rgb[rgbidx + 1] = intensity
    rgb[rgbidx + 2] = intensity
    

    done.inc
    let p = 100 * done div (WIDTH * HEIGHT)
    if p > lastPercent:
        echo "Done ", p, "%"
        lastPercent = p
        
discard savePNG24("output.png", rgb, WIDTH, HEIGHT)
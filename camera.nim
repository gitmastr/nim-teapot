import point

const camDir = Point(x: 0, y: 1, z: 0)
# apply rotX (tilt), then rotZ (pan)!

type
    Camera* = object 
        pos*: Point
        tilt*, pan*, fovMax*: float

iterator rays *(cam: Camera, width, height: int): tuple[u, v: int, r: Ray] =
    let 
        onePixel = cam.fovMax / min(height, width).float
        widthCenter = width.float / 2 - 0.5
        heightCenter = height.float / 2 - 0.5

    for v in 0 ..< height:
        let tilt = cam.tilt - onePixel * (v.float - heightCenter)
        for u in 0 ..< width:
            let pan = cam.pan - onePixel * (u.float - widthCenter)
            let rotatedx = camDir.rotx(tilt)
            # echo "rotatedx = ", rotatedx
            let rotatedz = rotatedx.rotz(pan)
            # echo "rotatedz = ", rotatedz
            yield (u, v, Ray(
                base: cam.pos,
                direction: rotatedz
            ))

package main

collision :: proc(x1,y1,w1,h1,x2,y2,w2,h2 : i32) -> bool {
    return (max(x1, x2) < min(x1 + w1, x2 + w2)) && (max(y1, y2) < min(y1 + h1, y2 + h2));
}

calcSlope :: proc(x1, y1, x2, y2: f32, dx, dy: ^f32) {
    steps := max(abs(x1-x2), abs(y1-y2))
    if steps == 0 {
        dx^ = 0
        dy^ = 0
        return
    }
    dx^ = x1-x2
    dx^ /= steps

    dy^ = y1-y2
    dy^ /= steps
}
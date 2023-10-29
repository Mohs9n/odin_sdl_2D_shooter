package main

import sdl "vendor:sdl2"
import sdlI "vendor:sdl2/image"

prepareScene :: proc() {
    sdl.SetRenderDrawColor(app.renderer, 10, 20, 30, 255)
    sdl.RenderClear(app.renderer)
}

presentScene :: proc() {
    sdl.RenderPresent(app.renderer)
}

loadTexture :: proc(filename: cstring) -> ^sdl.Texture {
    texture: ^sdl.Texture
    sdl.LogMessage(0, sdl.LogPriority.INFO, "Loading %s", filename)
    texture = sdlI.LoadTexture(app.renderer, filename)
    return texture
}

blit :: proc(texture: ^sdl.Texture, x,y: i32){
    dest: sdl.Rect
    dest.x = x
    dest.y = y
    sdl.QueryTexture(texture, nil, nil, &dest.w, &dest.h)
    sdl.RenderCopy(app.renderer, texture, nil, &dest)
}

drawGame:: proc() {
    drawFighters()
    drawBullets()
}

@(private="file")
drawPlayer :: proc() {
    blit(player.texture, i32(player.x), i32(player.y))
}

@(private="file")
drawBullets :: proc() {
    b: ^Entity
    for b= stage.bulletHead.next; b!=nil; b = b.next {
        blit(b.texture, i32(b.x), i32(b.y))
    }
}

@(private="file")
drawFighters :: proc() {
    e: ^Entity

    for e = stage.fighterHead.next; e!=nil ; e = e.next {
        blit(e.texture, i32(e.x), i32(e.y))
    }
}
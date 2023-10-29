package main

import "core:os"
import sdl "vendor:sdl2"

main :: proc(){
    then: u32
    remainder: f32

    initSDL()
    defer cleanup()

    initStage()
    then = sdl.GetTicks()    
    remainder = 0

    for {
        prepareScene()

        if doInput() do break

        gameLogic()

        drawGame()

        presentScene()

        capFrameRate(&then, &remainder)
        // sdl.Delay(8)
    }
}

@(private="file")
capFrameRate :: proc(then: ^u32, rem: ^f32) {
    wait, frameTime: u32
    wait = 16 + u32(rem^)
    rem^ -= rem^
    frameTime = sdl.GetTicks() - then^

    wait -= frameTime

    if wait < 1 do wait = 1

    sdl.Delay(wait)

    rem^ += 0.667

    then^ = sdl.GetTicks()
}
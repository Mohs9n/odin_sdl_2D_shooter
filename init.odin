package main

import sdl "vendor:sdl2"
import sdlI "vendor:sdl2/image"

initSDL :: proc() {
    rendererFlags, windowFlags := sdl.RENDERER_ACCELERATED, sdl.WINDOW_SHOWN
    init_err := sdl.Init(sdl.INIT_VIDEO)
    assert(init_err==0, sdl.GetErrorString())
    app.window = sdl.CreateWindow("Shooter 001", sdl.WINDOWPOS_CENTERED, sdl.WINDOWPOS_CENTERED, SCREEN_WIDTH, SCREEN_HEIGHT, windowFlags)

    assert(app.window!=nil, sdl.GetErrorString())
    sdl.SetHint(sdl.HINT_RENDER_SCALE_QUALITY, "linear")
    app.renderer = sdl.CreateRenderer(app.window, -1, rendererFlags)
    assert(app.renderer!=nil, sdl.GetErrorString())

    sdlI.Init(sdlI.INIT_PNG | sdlI.INIT_JPG)
}

cleanup :: proc() {
    sdl.DestroyWindow(app.window)
    sdl.DestroyRenderer(app.renderer)
    sdl.Quit()
}